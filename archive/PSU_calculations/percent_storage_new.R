library(odbc)
library(lubridate)
library(magrittr)
library(tidyverse)
library(pwdgsi)
library(assertthat)
library(ggplot2)
library(gridExtra)

#Establish a Database Connection
mars <- dbConnect(odbc(), "mars_testing")


# Return SMP rainfall events and CWL time series---------------------------------------------

  #Grab list of SMPs to run percent of storaged used (PSU) calcs on (based on greenit_subsurface_unlined_count_todo)
  smp_ow_query <- paste(" SELECT count(*) AS count,
                        r.ow_uid,
                        r.smp_id,
                        r.ow_suffix
                        FROM raw_owdata_smp r
                        JOIN greenit_subsurface_unlined gbu ON r.smp_id::text = gbu.smp_id::text
                        WHERE r.ow_suffix::text = 'OW1'::text
                        GROUP BY r.ow_uid, r.smp_id, r.ow_suffix
                        ORDER BY (count(*)) DESC;")
  
  smp_list <- dbGetQuery(mars, smp_ow_query)

  #Grab list of SMPs that have no PSU calculations yet (based on smpid_subsurface_unlined_count_todo)
  smp_new_ow_query <- paste(" SELECT count(*) AS count,
      r.ow_uid,
      r.smp_id,
      r.ow_suffix
     FROM raw_owdata_smp r
       JOIN greenit_subsurface_unlined gbu ON r.smp_id::text = gbu.smp_id::text
    WHERE r.ow_suffix::text = 'OW1'::text AND NOT (r.ow_uid IN ( SELECT prototype_pctstorage.ow_uid
             FROM prototype_pctstorage))
    GROUP BY r.ow_uid, r.smp_id, r.ow_suffix
    ORDER BY (count(*)) DESC;")
  
  smp_new_list <- dbGetQuery(mars,smp_new_ow_query)

  #Query SMP stats from "greenit_subsurface_unlined"
  stats_query <- paste0("SELECT * FROM greenit_subsurface_unlined")
  smp_statistics <- dbGetQuery(mars, stats_query)

  #Join stats to smp list
  smp_list <- left_join(smp_list, smp_statistics, by = "smp_id")

  #Query sump depth
  sump_query <- paste("SELECT * FROM ow_sumpdepth")
  sump_depth_ft <- dbGetQuery(mars, sump_query) 

  #Join sump depth to smp list
  smp_list <- left_join(smp_list, sump_depth_ft, by = "ow_uid")

  #Set unknown sump depth to 1 ft
  smp_list$sumpdepth_ft[is.na(smp_list$sumpdepth_ft)] <- 1

  #Query "latest rain event" for each ow_uid from the percent storage table
  ### @TODO@ Incorporate this into a view
  pctstorage_latest_query <- paste0("SELECT ow_uid, MAX(rainfall_gage_event_uid) AS max_event_uid FROM prototype_pctstorage GROUP BY ow_uid ORDER BY ow_uid;")
  pctstorage_latest <- dbGetQuery(mars, pctstorage_latest_query)
  
  #Get earliest "latest rain event"
  pctstorage_latest_min_event_uid <- min(pctstorage_latest$max_event_uid)

  #Get a latest date from the event uid
  ### @TODO@ Incorporate this into a view
  pctstorage_latest_date_query <- paste0("SELECT MIN(dtime_edt) dtime_edt 
                                         FROM rain_gage_event_join 
                                         WHERE rainfall_gage_event_uid = ", pctstorage_latest_min_event_uid)
  pctstorage_latest_min_date <- dbGetQuery(mars, pctstorage_latest_date_query)

  #Get the earliest date for OW that is not in the percent storage table
  ### @TODO@ Incorporate this into a view
  new_smp_start_query <- paste0("SELECT ow_uid, 
                                MIN(dtime_est) dtime_est 
                                FROM ow_leveldata 
                                WHERE ow_uid IN ('", paste(smp_new_list$ow_uid, collapse = '\', \''), "') 
                                GROUP BY ow_uid")
  new_smp_start <- dbGetQuery(mars, new_smp_start_query)
  new_smp_min_start_date <- min(new_smp_start$dtime_est)

  #Get the earlier date of "latest dates" and "first new date"  
  new_smp_min_start_date <- min(pctstorage_latest_min_date$dtime_edt, new_smp_min_start_date)

  #dst start time
  new_smp_min_start_date %<>% force_tz("EST")
  start_is_dst <- new_smp_min_start_date %>% force_tz("America/New_York") %>% dst
  
  if(start_is_dst){
    start_time <- new_smp_min_start_date %>% force_tz("America/New_York") + hours(1)
    } else {
      start_time <- new_smp_min_start_date %>% force_tz("EST")
    }

  #Query all gage uids, for use in selecting rainfall 
  gage_query <- paste0("SELECT smp_id, gage_uid FROM smp_gage WHERE smp_id IN ('", paste(smp_list$smp_id, collapse = '\', \''), "')")
  smp_gage <- dbGetQuery(mars, gage_query)
  gage <- smp_gage %>% dplyr::select(gage_uid) %>% unique()

  #Query rainfall
  rainfall_query <- paste0("SELECT * FROM rain_gage_event_join 
                           WHERE gage_uid IN ('", paste(gage$gage_uid, collapse = '\', \''), "') 
                           AND dtime_edt > '", (start_time), "'")
  smp_rainfall <- dbGetQuery(mars, rainfall_query)  
  
  # smp_rainfall_distinct <- smp_rainfall %>% 
  #   group_by(rainfall_gage_event_uid) %>% 
  #   summarize(max(dtime_edt)) 
    

  #Join dates to latest event uid per smp ID, and add both to smp_list
  pctstorage_latest_join <- left_join(pctstorage_latest, smp_rainfall, by = c("max_event_uid" = "rainfall_gage_event_uid")) %>% 
    arrange(ow_uid, desc(dtime_edt)) %>% 
    distinct(ow_uid, max_event_uid, .keep_all = TRUE) %>% 
    dplyr::select(ow_uid, dtime_edt)

  #Bind date for new smp(s) to the ow_uid - latest dates table
  new_smp_start %<>% set_colnames(c("ow_uid", "dtime_edt"))
  pctstorage_latest_join <- bind_rows(pctstorage_latest_join, new_smp_start)

  #Join ow_uid - latest dates table to smp_list
  smp_list <- left_join(smp_list, pctstorage_latest_join, by = "ow_uid")

  #Join gage to smp list
  smp_list <- left_join(smp_list, smp_gage, by = "smp_id")

  #Query SMP series
  smp_query <- paste0("SELECT * FROM raw_owdata_smp 
                      WHERE ow_uid IN ('", paste(smp_list$ow_uid, collapse = '\', \''), "') 
                      AND dtime_est > '", start_time, "'")
  smp_series <- dbGetQuery(mars, smp_query) 

  #Query full percent of storage table
  pctstorage_existing_query <- paste0("SELECT * FROM prototype_pctstorage")
  pctstorage_existing <- dbGetQuery(mars, pctstorage_existing_query)

  #Intialize new percent of storage table
  percentstorage <- data.frame("rainfall_gage_event_uid" = integer(),
                               "percentstorageused_peak" = numeric(),
                               "ow_uid" = integer(),
                               "percentstorageused_relative" = numeric())

#Filter respective smp and rainfall series, then adjust rainfall to be EST. 
#Get sump depth and subtract that from recorded water level
#Then summarize the percent storage using the function, and relative percent storage by subtracting starting depth
#Finally, add new rows to the "percentstorage" table
  
  for(i in 1:length(smp_list$smp_id)){
    smp_new_series <- smp_series %>% 
      filter(smp_id == smp_list$smp_id[i]) %>% 
      filter(dtime_est > smp_list$dtime_edt[i]) %>% #get a date to go with the latest rain event for this/each system
      arrange(dtime_est)
    
    smp_new_series$dtime_est <- lubridate::round_date(smp_new_series$dtime_est, "1 minutes")
      
    smp_new_rainfall <- smp_rainfall %>% 
      filter(gage_uid == smp_list$gage_uid[i]) %>% 
      filter(dtime_edt > smp_list$dtime_edt[i])
      
    smp_new_rainfall$dtime_edt %<>% lubridate::force_tz("America/New_York")
    #Attempting to set the time zone on a datetime that falls squarely on the spring forward datetime
    #Such as 2005-04-03 02:00:00
    #Returns NA, because the time is impossible.
    #To mitigate this, we will strip NA values from the new object
    smp_new_rainfall %<>% dplyr::filter(!is.na(dtime_edt))
    
    #Our water level data is not corrected for daylight savings time. ie it doesn't spring forwards
    #So we must shift back any datetimes within the DST window so rainfall data lines up with water level data
    #Thankfully, the dst() function returns TRUE if a dtime is within that zone
    dst_index <- lubridate::dst(smp_new_rainfall$dtime_edt)
    smp_new_rainfall$dtime_edt %<>% lubridate::force_tz("EST") #Assign new TZ without changing dates
    smp_new_rainfall$dtime_edt[dst_index] <- smp_new_rainfall$dtime_edt[dst_index] - lubridate::hours(1)
    colnames(smp_new_rainfall)[1] <- "dtime_est"
    
    #subtract sumpdepth from level
    smp_new_series$level_ft <- smp_new_series$level_ft - smp_list$sumpdepth_ft[i]
    smp_new_series$level_ft[smp_new_series$level_ft < 0] <- 0
    
    #Attach rain event UID to CWL time series 
    smp_rain_cwl <- full_join(smp_new_series, smp_new_rainfall, by = "dtime_est")
    
    percentstorage_new <- smp_rain_cwl %>%
      arrange(dtime_est) %>% 
      fill(rainfall_gage_event_uid) %>% #fill event IDs so all rain data will correspond to an event ID
      filter(is.na(rainfall_gage_event_uid) == FALSE) %>% #remove rows that had water level data but no event ID
      filter(is.na(level_ft) == FALSE)
    if(nrow(percentstorage_new) == 0){ #add a conditional to skip over calc if there is no data to enter. Returns an error otherwise.
      next
    }
    #%>% #remove rows that had event ID but no water level data
    percentstorage_new %<>%   
      group_by(rainfall_gage_event_uid) %>%
      summarize(
        
        #Observed storage utilization
        percentstorageused_peak = peakStorUtil_percent(waterlevel_ft = level_ft, storage_depth_ft = smp_list$storage_depth_ft[i]),
        
        #Ow uid
        ow_uid = ow_uid[1],
        
        #Observed relative storage utilization
        percentstorageused_relative = peakStorUtil_percent(waterlevel_ft = level_ft - dplyr::first(level_ft), storage_depth_ft = smp_list$storage_depth_ft[i])
        
        #Draindown time
        #Draindown_hr = draindown_hr(dtime_est, rainfall_in, waterlevel_ft = level_ft)
      )
    #bind new rows
    percentstorage <- dplyr::bind_rows(percentstorage, percentstorage_new) 
     
  }
  
  #write csv for review
  write.csv(percentstorage, "A:/Scripts/Misc/percent_storage_new_20190823.csv")
  
  #add line to write to percent storage table in mars_testing when ready
  
  
  

