library(odbc)
library(tidyverse)
library(lubridate)

  truncate_new_tables <- TRUE
  seriously <- TRUE

  mars_9 <- dbConnect(odbc(), "mars_testing")
  mars_12 <- dbConnect(odbc(), "mars_brian")
  # mars_12 <- dbConnect(odbc(), "mars_data")

#Writing data tables from PG9 to PG12
#Old Tables
  baro_old <- "public.baro"
  gage_event_old <- "public.rainfall_gage_event"
  gage_rain_old <- "public.rainfall_gage_raw"
  gw_old <- "public.gw_depthdata_raw"
  ow_old <- "public.ow_leveldata_raw"
  radar_event_old <- "public.rainfall_radarcell_event"
  radar_rain_old <- "public.rainfall_radarcell_raw"
  old_tables <- c(baro_old, gage_event_old, gage_rain_old, ow_old, gw_old, radar_event_old, radar_rain_old)
  
#New Tables
  baro_new <- "data.baro"
  gage_event_new <- "data.gage_event"
  gage_rain_new <- "data.gage_rain"
  gw_new <- "data.gw_depthdata_raw"
  ow_new <- "data.ow_leveldata_raw"
  radar_event_new <- "data.radar_event"
  radar_rain_new <- "data.radar_rain"
  new_tables <- c(baro_new, gage_event_new, gage_rain_new, gw_new, ow_new, radar_event_new, radar_rain_new)


#New Sequences
  baro_sequence <- "data.baro_baro_uid_seq"
  gage_event_sequence <- "data.gage_event_gage_event_uid_seq"
  gage_rain_sequence <- "data.gage_rain_gage_rain_uid_seq"
  gw_sequence <- "data.gw_depthdata_raw_gw_depthdata_uid_seq"
  ow_sequence <- "data.ow_leveldata_raw_ow_leveldata_uid_seq"
  radar_event_sequence <- "data.radar_event_radar_event_uid_seq"
  radar_rain_sequence <- "data.radar_rain_radar_rain_uid_seq"
  new_sequences <- c(baro_sequence, gage_event_sequence, gage_rain_sequence, gw_sequence, ow_sequence, radar_event_sequence, radar_rain_sequence)

  
tables <- data.frame(old_tables, new_tables, new_sequences)

#Transfer data
for(j in 1:nrow(tables)){
  #New table truncation
  if(truncate_new_tables & seriously){
    dbGetQuery(mars_12, paste("truncate", tables$new_tables[j]))
    dbGetQuery(mars_12, paste("alter sequence", tables$new_sequences[j], "restart with 1"))
  }
  
  if(tables$new_tables[j] == "data.ow_leveldata_raw"){
    next #This actually makes us run out of memory. Do this one manually.
  }
  
  old_data <- dbGetQuery(mars_9, paste("select * from", tables$old_tables[j]))
  for(i in 1:ncol(old_data)){
    if(ncol(old_data) == 0){
      break
    }
    
    #Non-integer numerics need to be hit with a round(4)
    if(is.numeric(old_data[1, i]) & !is.integer(old_data[1, i])){
      old_data[, i] <- round(old_data[, i], 4)
      next
    }
  }

  #Export new data
  setwd("//pwdoows/OOWS/Watershed Sciences/GSI Monitoring/07 Databases and Tracking Spreadsheets/13 MARS Analysis Database/PG12 Migration/Migration Data")
  write.csv(old_data, file = paste(strftime(now(), format="%Y%m%d"), tables$new_tables[j], ".csv", sep = "_"), row.names = FALSE)
  rm(old_data)
}
dbDisconnect(mars_9)
dbDisconnect(mars_12)
