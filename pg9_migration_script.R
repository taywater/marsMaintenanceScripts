#Note: much of this code is predicated on the assumption of the primary key of a
#table is stored within the first column of that table. Any alteration to that
#assumption would render this code effectively useless. This is something to
#eventually correct, but seems outside the scope of the task.


library(odbc)
library(tidyverse)
library(lubridate)
library(magrittr)
library(digest)
library(magrittr)


  truncate_new_tables <- FALSE
  seriously <- TRUE

  
  #connect to testing database-
  mars_9 <- dbConnect(odbc(), "mars_testing")
  
  #testing mode
  mars_12 <- dbConnect(odbc(), "mars_brian")
  #write mode
  # mars_12 <- dbConnect(odbc(), "mars_data")
  
  cons <- list(mars_9,mars_12)

#Writing data tables from PG9 to PG12
#Read parent foreign key tables from PG9
  ow_old <- "fieldwork.ow_all"
  gage_old <- "public.gage"
  radar_old <- "public.radarcell"
  con_phase_lookup_old <- "fieldwork.con_phase_lookup"
  est_high_flow_efficiency_lookup_old <- "fieldwork.est_high_flow_efficiency_lookup"
  inventory_sensors_old <- "fieldwork.inventory_sensors"
  long_term_lookup_old <- "fieldwork.long_term_lookup"
  research_lookup_old <- "fieldwork.research_lookup"
  field_test_priority_lookup_old <- "fieldwork.field_test_priority_lookup"
  surface_type_lookup_old <- "fieldwork.surface_type_lookup"
  request_by_lookup_old <- "fieldwork.requested_by_lookup"
  special_investigation_lookup_old <- "fieldwork.special_investigation_lookup"
  srt_type_lookup_old <- "fieldwork.srt_type_lookup"
  sensor_issue_lookup_old <- "fieldwork.sensor_issue_lookup"
  sensor_model_lookup_old <- "fieldwork.sensor_model_lookup"
  sensor_status_lookup_old <- "fieldwork.sensor_status_lookup"
  porous_pave_old <- "fieldwork.porous_pavement"
  draindown_assessment_lookup_old <- "public.performance_draindown_assessment_lookup"
  observed_simulated_lookup_old <- "public.observed_simulated_lookup"
  snapshot_old <- "public.snapshot"
  
  old_table_names <- c(ow_old, gage_old, radar_old, con_phase_lookup_old, est_high_flow_efficiency_lookup_old, inventory_sensors_old,long_term_lookup_old, research_lookup_old, field_test_priority_lookup_old, surface_type_lookup_old, request_by_lookup_old, special_investigation_lookup_old, srt_type_lookup_old, sensor_issue_lookup_old, sensor_model_lookup_old, sensor_status_lookup_old, porous_pave_old, draindown_assessment_lookup_old, observed_simulated_lookup_old, snapshot_old)
  #all old table names
  old_table_names <- c("public.accessdb", "public.baro_rawfile", "public.baro_rawfolder", "public.class_asset_surface", "public.gage", "public.gage_loc", "public.radarcell", "public.radarcell_loc", "public.radarcell_rawfile", "public.smp_gage", "public.smp_loc", "public.smp_radarcell", "public.baro", "public.rainfall_gage_event", "public.rainfall_gage_raw", "public.gw_depthdata_raw", "public.ow_leveldata_raw", "public.rainfall_radarcell_event", "public.rainfall_radarcell_raw", "fieldwork.capture_efficiency", "fieldwork.con_phase_lookup", "public.custom_project_names", "fieldwork.deployment", "fieldwork.est_high_flow_efficiency_lookup", "fieldwork.field_test_priority_lookup", "fieldwork.future_capture_efficiency", "fieldwork.future_deployment", "fieldwork.future_inlet_conveyance", "fieldwork.future_porous_pavement", "fieldwork.future_special_investigation", "fieldwork.future_srt", "fieldwork.gswi_conveyance_subtype_lookup", "fieldwork.inlet_conveyance", "fieldwork.inventory_sensors", "fieldwork.long_term_lookup", "fieldwork.monitoring_deny_list", "fieldwork.ow_all", "fieldwork.ow_prefixes", "public.ow_sumpdepth_default", "public.ow_sumpdepth_intermediate", "fieldwork.porous_pavement", "fieldwork.porous_pavement_maintenance", "fieldwork.porous_pavement_results", "fieldwork.requested_by_lookup", "fieldwork.research_lookup", "fieldwork.sensor_issue_lookup", "fieldwork.sensor_model_lookup", "fieldwork.sensor_status_lookup", "fieldwork.site_name_lookup", "fieldwork.special_investigation", "fieldwork.special_investigation_lookup", "fieldwork.srt", "fieldwork.srt_type_lookup", "fieldwork.surface_type_lookup", "fieldwork.well_measurements", "public.performance_draindown_assessment_lookup", "public.performance_error_lookup", "performance.eventdepth_bin_lookup", "public.observed_simulated_lookup", "performance.relative_eventdepth_bin_lookup", "public.snapshot", "public.snapshot_metadata")
    
#Read parent foreign key tables from PG9  
  ow_new <- "fieldwork.ow"
  gage_new <- "admin.gage"
  radar_new <- "admin.radar"
  con_phase_lookup_new <- "fieldwork.con_phase_lookup"
  est_high_flow_efficiency_lookup_new <- "fieldwork.est_high_flow_efficiency_lookup"
  inventory_sensors_new <- "fieldwork.inventory_sensors"
  long_term_lookup_new <- "fieldwork.long_term_lookup"
  research_lookup_new <- "fieldwork.research_lookup"
  field_test_priority_lookup_new <- "fieldwork.field_test_priority_lookup"
  surface_type_lookup_new <- "fieldwork.surface_type_lookup"
  requested_by_lookup_new <- "fieldwork.requested_by_lookup"
  special_investigation_lookup_new <- "fieldwork.special_investigation_lookup"
  srt_type_lookup_new <- "fieldwork.srt_type_lookup"
  sensor_issue_lookup_new <- "fieldwork.sensor_issue_lookup"
  sensor_model_lookup_new <- "fieldwork.sensor_model_lookup"
  sensor_status_lookup_new <- "fieldwork.sensor_status_lookup"
  porous_pavement_new <- "fieldwork.porous_pavement"
  draindown_assessment_lookup_new <- "metrics.draindown_assessment_lookup"
  # error_lookup_new <- "metrics.error_lookup"
  observed_simulated_lookup_new <- "metrics.observed_simulated_lookup"
  snapshot_new <- "metrics.snapshot"
  
  #non foreign-key tables
  
  
  # new_table_names <- c(ow_new, gage_new, radar_new, con_phase_lookup_new, est_high_flow_efficiency_lookup_new, inventory_sensors_new, long_term_lookup_new, research_lookup_new, field_test_priority_lookup_new, surface_type_lookup_new, requested_by_lookup_new, special_investigation_lookup_new, srt_type_lookup_new, sensor_issue_lookup_new, sensor_model_lookup_new, sensor_status_lookup_new, porous_pavement_new, draindown_assessment_lookup_new, error_lookup_new, observed_simulated_lookup_new, snapshot_new)
  new_table_names <- c(ow_new, gage_new, radar_new, con_phase_lookup_new, est_high_flow_efficiency_lookup_new, inventory_sensors_new, long_term_lookup_new, research_lookup_new, field_test_priority_lookup_new, surface_type_lookup_new, requested_by_lookup_new, special_investigation_lookup_new, srt_type_lookup_new, sensor_issue_lookup_new, sensor_model_lookup_new, sensor_status_lookup_new, porous_pavement_new, draindown_assessment_lookup_new, observed_simulated_lookup_new, snapshot_new) 
  #all new table names
  new_table_names <- c("admin.accessdb", "admin.baro_rawfile", "admin.baro_rawfolder", "admin.class_asset_surface", "admin.gage", "admin.gage_loc", "admin.radar", "admin.radar_loc", "admin.radar_rawfile", "admin.smp_gage", "admin.smp_loc", "admin.smp_radar", "data.baro", "data.gage_event", "data.gage_rain", "data.gw_depthdata_raw", "data.ow_leveldata_raw", "data.radar_event", "data.radar_rain", "fieldwork.capture_efficiency", "fieldwork.con_phase_lookup", "fieldwork.custom_project_names", "fieldwork.deployment", "fieldwork.est_high_flow_efficiency_lookup", "fieldwork.field_test_priority_lookup", "fieldwork.future_capture_efficiency", "fieldwork.future_deployment", "fieldwork.future_inlet_conveyance", "fieldwork.future_porous_pavement", "fieldwork.future_special_investigation", "fieldwork.future_srt", "fieldwork.gswi_conveyance_subtype_lookup", "fieldwork.inlet_conveyance", "fieldwork.inventory_sensors", "fieldwork.long_term_lookup", "fieldwork.monitoring_deny_list", "fieldwork.ow", "fieldwork.ow_prefixes", "fieldwork.ow_sumpdepth_default", "fieldwork.ow_sumpdepth_intermediate", "fieldwork.porous_pavement", "fieldwork.porous_pavement_maintenance", "fieldwork.porous_pavement_results", "fieldwork.requested_by_lookup", "fieldwork.research_lookup", "fieldwork.sensor_issue_lookup", "fieldwork.sensor_model_lookup", "fieldwork.sensor_status_lookup", "fieldwork.site_name_lookup", "fieldwork.special_investigation", "fieldwork.special_investigation_lookup", "fieldwork.srt", "fieldwork.srt_type_lookup", "fieldwork.surface_type_lookup", "fieldwork.well_measurements", "metrics.draindown_assessment_lookup", "metrics.error_lookup", "metrics.eventdepth_bin_lookup", "metrics.observed_simulated_lookup", "metrics.relative_eventdepth_bin_lookup", "metrics.snapshot", "metrics.snapshot_metadata")

  
#Append new data from PG9 to corresponding PG12 tables
#pull data
  
#query data functions
  pg9_query <- function(table){
    dbGetQuery(mars_9,paste0("SELECT * FROM ",table))
  }
  pg12_query <- function(table){
    dbGetQuery(mars_12,paste0("SELECT * FROM ",table))
  }
 
#query data type function
  pg9_data_type_query <- function(table){
    schema_table <- stringr::str_split_fixed(table, pattern = "\\.", n = 2)
    data_type_query_string <- paste0("SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = '", schema_table[1], "' AND TABLE_NAME = '",schema_table[2],"'")
    dbGetQuery(mars_9,data_type_query_string)
  }
  
  pg12_data_type_query <- function(table){
    schema_table <- stringr::str_split_fixed(table, pattern = "\\.", n = 2)
    data_type_query_string <- paste0("SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = '", schema_table[1], "' AND TABLE_NAME = '",schema_table[2],"'")
    dbGetQuery(mars_12,data_type_query_string)
  }  
   
#query data
old_tables <- lapply(old_table_names, pg9_query)
new_tables <- lapply(new_table_names, pg12_query)

#query data types
old_data_types <- lapply(old_table_names, pg9_data_type_query)
new_data_types <- lapply(new_table_names, pg12_data_type_query)

#add names
names(old_tables) <- old_table_names
names(new_tables) <- new_table_hashes
names(old_data_types) <- old_table_names
names(new_data_types) <- new_table_names
  
#create hash function
hash_table <- function(table){
  data.frame(uid = table[,1], hash = apply(table, 1, digest))
  }  

#apply hash function across old and new tables 
old_table_hashes <- lapply(old_tables,hash_table)
new_table_hashes <- lapply(new_tables,hash_table)


#remove uid and apply hash
no.uid.hash.table <- function(table){
  uid_table <- table[,1]  #grab uids
  if(ncol(table) > 1){
  no_uid_table <- as.data.frame(table[,2:ncol(table)])  #remove uids 
  no_uid_table_hash <- data.frame(hash = apply(no_uid_table, 1, digest))  #hash table without uids
  data.frame(uid = uid_table, no_uid_hash = no_uid_table_hash)
  }
}

old_table_hashes_no_uid <- lapply(old_tables,no.uid.hash.table)
new_table_hashes_no_uid <- lapply(new_tables,no.uid.hash.table)

#record entries altered between tables
diff_entries <- list() # anti_join new onto old
diff_entries_2 <- list() #anti_join old onto new

for(i in 1:length(old_table_hashes)){
  # diff_entries[[i]] <- anti_join(old_table_hashes[[i]],new_table_hashes[[i]], by = "hash")
  x <- anti_join(old_table_hashes[[i]],new_table_hashes[[i]], by = "hash")
  y <- dplyr::filter(old_tables[[i]], !!as.name(colnames(old_tables[[i]])[1]) %in% x$uid)
  diff_entries[[i]] <- y
  
  
  #check for alterd uid's
  w <- anti_join(new_table_hashes[[i]], old_table_hashes[[i]], by = "hash")
  z <- dplyr::filter(new_tables[[i]], !!as.name(colnames(new_tables[[i]])[1]) %in% w$uid)
  diff_entries_2[[i]] <- z
  }


#Define "not in" operator for filtering
`%!in%` <- Negate(`%in%`)

#Create lists for 3 queries: entries to delete, alter, and append
delete_tables <- list()
alter_tables <- list()
append_tables <- list()

#Creates delete, alter, and append lists from the diff_entries lists
 for(i in 1:length(new_tables)){

   #remove entries from the new table with uid's in the diff table
   #this leaves entries that are either a) unchanged between the two tables or b) present in pg12 (new_tables) but not pg9 (old_tables)
   x <- dplyr::filter(new_tables[[i]], !!as.name(colnames(new_tables[[i]])[1]) %!in% diff_entries[[i]][[1]])

   #Create delete table using negation
   #Remove group a) by selecting entries that are within x but not within the old table
   delete_tables[[i]] <- dplyr::filter(x, !!as.name(colnames(x)[1]) %!in% old_tables[[i]][[1]])

   #Find altered entries
   y <- dplyr::filter(new_tables[[i]], !!as.name(colnames(new_tables[[i]])[1]) %in% diff_entries[[i]][[1]])
   alter_tables[[i]] <- y

   #Find new entries to append

   #remove entries from the old table with uid's in the diff table
   #this leaves entries that are either a) unchanged between the two tables or b) present in pg9 (old_tables) but not pg12 (new_tables)
   z <- dplyr::filter(old_tables[[i]], !!as.name(colnames(old_tables[[i]])[1]) %!in% diff_entries[[i]][[1]])
   #remove group a) by selecting entries that are within z but not within the new table
   append_tables[[i]]  <- z %>% dplyr::filter(!!as.name(colnames(z)[1]) %!in% new_tables[[i]][[1]])
   check <-  dplyr::filter(z, !!as.name(colnames(z)[1]) %!in% new_tables[[i]][[1]])

   }

#Sanity check
for(i in 1:length(diff_entries)){
  if(nrow(diff_entries[[i]]) == (nrow(delete_tables[[i]]) + nrow(alter_tables[[i]]) + nrow(append_tables[[i]]))){
    print(paste0("Table ",i," is OK."))
  } else
    print(paste0("Check Table ",i,"."))
}

# pass tables to respective queries in pg12
# order of: alter, append, delete

#ALTER
alter_query_fx <- function(names,values,data_types){
  x = ""
  for(k in 1:length(values)){
    x <- paste0(x,names[k]," = '", values[k],"'::",data_types[k])
    if(k < length(values)){ x <- paste0(x,", ")}
  }
  x <- gsub("'NA'","NULL",x)
  x <- gsub("\\'(\\d+)\\'","\\1",x)
  return(x)
}

 for(i in 1:length(alter_tables)){
   if(seriously == TRUE & nrow(alter_tables[[i]]) > 0){
     col_names <- colnames(alter_tables[[i]])
     uid_name <- col_names[1]
     uid_upd_list <- alter_tables[[i]][,1]
     data_types <- new_data_types[[i]] %>% unlist() %>% as.vector()
     for(j in 1:length(uid_upd_list)){
       x <- alter_query_fx(col_names,alter_tables[[i]][j,],data_types)
       alt_query <- paste0("UPDATE ",new_table_names[i]," SET ",x, " WHERE ",uid_name," = ",uid_upd_list[j],";")
       print(alt_query)
       rs<- dbSendQuery(mars_12, alt_query)
       dbFetch(rs)
       dbClearResult(rs)
     }
   }
 }

#APPEND
append_query_fx <- function(values,data_types){
  x = "("
  for(k in 1:length(values)){
    x <- paste0(x,"'", values[k],"'::",data_types[k])
    if(k < length(values)){ x <- paste0(x,", ")}
  }
  x <- gsub("'NA'","NULL",x)
  x <- gsub("\\'(\\d+)\\'","\\1",x)
  x <- paste0(x,")")
  return(x)
}

for(i in 1:length(append_tables)){
  if(seriously == TRUE & nrow(append_tables[[i]] > 0)){
      col_names <- colnames(append_tables[[i]])
      uid_name <- col_names[1]
      uid_upd_list <- append_tables[[i]][,1]
      data_types <- new_data_types[[i]] %>% unlist() %>% as.vector()
      for(j in 1:length(uid_upd_list)){
        x <- append_query_fx(append_tables[[i]][j,],data_types)
        print(paste0("INSERT INTO ", new_table_names[i]," VALUES ",x))
        append_query <- paste0("INSERT INTO ", new_table_names[i]," VALUES ",x)
        }
    }
}

#DELETE
for(i in 1:length(delete_tables)){
  if(seriously == TRUE & nrow(delete_tables[[i]]) > 0){
    uid_name <- colnames(new_tables[[i]])[1]
    uid_del_list <- paste(delete_tables[[i]][,1], collapse = ", ")
    del_query <- paste0("DELETE FROM ",new_table_names[i]," WHERE ", uid_name, " IN (", uid_del_list,")")
    print(del_query)
    dbSendQuery(mars_12, del_query)
  }
}




# for(i in 1:length(diff_entries)){
# #delete query
#   if(seriously == TRUE & nrow(diff_entries[[i]]) > 0){
#     #delete entries    
#     uid_name <- colnames(new_tables[[i]])[1]
#     uid_del_list <- paste(diff_entries[[i]][,1], collapse = ", ")
#     del_query <- paste0("DELETE * FROM ",new_table_names[i]," WHERE ", uid_name, " IN (", uid_del_list,")")
#     dbGetQuery(mars_12, del_query)
#     #write entries    
#     for(j in 1:nrow(diff_entries[[i]])){
#       table_cols <- paste(colnames(new_tables[[i]]), collapse = ", ")
#       values <- paste0("'",paste(new_tables[[i]][j,], collapse = "','"),"'")
#       #regular expression express
#       values <- gsub("'NA'","NULL",values)
#       values <- gsub("\\'(\\d+)\\'","\\1",values)
#       insert_query <- paste0("INSERT INTO ", new_table_names[i], " (", table_cols,") VALUES (", values,")")
#       dbGetQuery(mars_12,insert_query)
#     }
#   }
# }

# #View all tables
# all_old_tables <- c("fieldwork.sensor_model_lookup", "fieldwork.porous_pavement", "fieldwork.porous_pavement_results", "fieldwork.deployment_backup", "fieldwork.research_lookup", "fieldwork.ow_prefixes", "fieldwork.site_name_lookup", "fieldwork.well_measurements", "fieldwork.deployment_lookup", "fieldwork.gswi_conveyance_subtype_lookup", "fieldwork.est_high_flow_efficiency_lookup", "fieldwork.capture_efficiency", "fieldwork.future_capture_efficiency", "fieldwork.field_test_priority_lookup", "fieldwork.future_inlet_conveyance", "fieldwork.requested_by_lookup", "fieldwork.deployment", "fieldwork.long_term_lookup", "fieldwork.inlet_conveyance", "fieldwork.ow_all", "fieldwork.future_deployment", "fieldwork.con_phase_lookup", "fieldwork.srt", "fieldwork.inventory_sensors", "fieldwork.future_porous_pavement", "fieldwork.special_investigation_lookup", "fieldwork.surface_type_lookup", "fieldwork.sensor_issue_lookup", "fieldwork.future_special_investigation", "fieldwork.special_investigation", "fieldwork.sensor_status_lookup", "fieldwork.srt_type_lookup", "fieldwork.future_srt", "fieldwork.monitoring_deny_list", "fieldwork.porous_pavement_maintenance", "performance.eventdepth_bin_lookup", "performance.relative_eventdepth_bin_lookup", "public.performance_draindown_assessment_lookup", "public.baro", "public.ow_leveldata_raw", "public.radarcell_rawfile", "public.gswi_conveyance_subtype_lookup", "public.baro_rawfile", "public.radarcell", "public.performance_draindown_radarcell", "public.performance_infiltration_radarcell", "public.smp_radarcell", "public.short_long", "public.rainfall_gage_bin_intensity_lookup", "public.prototype_pctstorage", "public.performance_overtopping_radarcell", "public.custom_project_names", "public.smp_loc", "public.deployment_lookup_table", "public.billyquery2", "public.billyquery1", "public.class_asset_surface", "public.deployment_testing", "public.ow_sumpdepth_default", "public.ow_prefixes", "public.privilege_test", "public.radarcell_loc", "public.performance_percentstorage_radarcell", "public.baro_rawfolder", "public.ow_sumpdepth_intermediate", "public.rainfall_radarcell_test", "public.ow_leveldata_entrydates", "public.accessdb", "public.smp_gage", "public.gage_loc", "public.liner_description_lookup", "public.liner_spec", "public.snapshot", "public.gw_depthdata_raw", "public.gage", "public.snapshot_metadata", "public.rainfall_gage_raw", "public.performance_draindown", "public.performance_overtopping", "public.rainfall_gage_event", "public.rainfall_radarcell_raw", "public.performance_infiltration", "public.observed_simulated_lookup", "public.rainfall_radarcell_event", "public.performance_error_lookup", "public.performance_draindown_scratch", "public.performance_percentstorage")
# all_new_tables <- c("admin.accessdb", "admin.baro_rawfile", "admin.baro_rawfolder", "admin.class_asset_surface", "admin.gage", "admin.gage_loc", "admin.purge", "admin.radar", "admin.radar_loc", "admin.radar_rawfile", "admin.smp_gage", "admin.smp_loc", "admin.smp_radar", "admin.sump_increase", "admin.timezonetest", "data.baro", "data.gage_event", "data.gage_rain", "data.gw_depthdata_raw", "data.ow_leveldata_raw", "data.radar_event", "data.radar_rain", "external.cipit_project", "external.gswibasin", "external.gswiblueroof", "external.gswibumpout", "external.gswicistern", "external.gswicleanout", "external.gswicontrolstructure", "external.gswiconveyance", "external.gswiconveyance_lookup", "external.gswidrainagewell", "external.gswifitting", "external.gswigreenroof", "external.gswiinlet", "external.gswimanhole", "external.gswiobservationwell", "external.gswipermeablepavement", "external.gswiplanter", "external.gswiraingarden", "external.gswistructure", "external.gswiswale", "external.gswitree", "external.gswitreetrench", "external.gswitrench", "external.gswiwetland", "external.planreview_view_smp_designation", "external.planreview_view_smpsummary_crosstab_asbuiltall", "external.projectbdv", "external.smpbdv", "external.systembdv", "fieldwork.capture_efficiency", "fieldwork.con_phase_lookup", "fieldwork.custom_project_names", "fieldwork.deployment", "fieldwork.est_high_flow_efficiency_lookup", "fieldwork.field_test_priority_lookup", "fieldwork.future_capture_efficiency", "fieldwork.future_deployment", "fieldwork.future_inlet_conveyance", "fieldwork.future_porous_pavement", "fieldwork.future_special_investigation", "fieldwork.future_srt", "fieldwork.gswi_conveyance_subtype_lookup", "fieldwork.inlet_conveyance", "fieldwork.inventory_sensors", "fieldwork.long_term_lookup", "fieldwork.monitoring_deny_list", "fieldwork.ow", "fieldwork.ow_prefixes", "fieldwork.ow_sumpdepth_default", "fieldwork.ow_sumpdepth_intermediate", "fieldwork.porous_pavement", "fieldwork.porous_pavement_maintenance", "fieldwork.porous_pavement_results", "fieldwork.requested_by_lookup", "fieldwork.research_lookup", "fieldwork.sensor_issue_lookup", "fieldwork.sensor_model_lookup", "fieldwork.sensor_purpose_lookup", "fieldwork.sensor_status_lookup", "fieldwork.site_name_lookup", "fieldwork.special_investigation", "fieldwork.special_investigation_lookup", "fieldwork.srt", "fieldwork.srt_type_lookup", "fieldwork.surface_type_lookup", "fieldwork.well_measurements", "metrics.draindown", "metrics.draindown_assessment_lookup", "metrics.draindown_oldsims", "metrics.error_lookup", "metrics.eventdepth_bin_lookup", "metrics.infiltration", "metrics.observed_simulated_lookup", "metrics.overtopping", "metrics.overtopping_oldsims", "metrics.percentstorage", "metrics.percentstorage_oldsims", "metrics.relative_eventdepth_bin_lookup", "metrics.snapshot", "metrics.snapshot_metadata")
# 
# old_table_sizes <- as.data.frame(matrix(data = NA,ncol = 2, nrow = length(all_old_tables)))
# for(i in 1:length(all_old_tables)){
#  old_table_sizes$Name[i] <- all_old_tables[i]
#  old_table_sizes$Size_kb[i] <- dbGetQuery(mars_9,paste0("SELECT pg_table_size('",all_old_tables[i],"');"))[[1]]/1024
# }
# old_table_sizes %<>% dplyr::select(-"V1",-"V2")
# 
# new_table_sizes <- as.data.frame(matrix(data = NA,ncol = 2, nrow = length(all_new_tables)))
# for(i in 1:length(all_new_tables)){
#   new_table_sizes$Name[i] <- all_new_tables[i]
#   new_table_sizes$Size_kb[i] <- dbGetQuery(mars_12,paste0("SELECT pg_table_size('",all_new_tables[i],"');"))[[1]]/1024
# }
# new_table_sizes %<>% dplyr::select(-"V1",-"V2")
# 
# setwd("//pwdoows/OOWS/Watershed Sciences/GSI Monitoring/07 Databases and Tracking Spreadsheets/13 MARS Analysis Database/PG12 Migration/Migration Data")
# write.csv(x = old_table_sizes, file = "PG9 Table Sizes.csv")
# write.csv(x = new_table_sizes, file = "PG12 Table Sizes.csv")

dbDisconnect(mars_9)
dbDisconnect(mars_12)


