#PG9 migration script

#Note: much of this code is predicated on the assumption of the primary key of a
#table is stored within the first column of that table. Any alteration to that
#assumption would render this code effectively useless. This is something to
#eventually correct, but seems outside the scope of the task.

#Second (third) attempt at creating script for the entirety of the database, since original
#attempt exceeded available memory (see "pg9_migration_script.R")


library(odbc)
library(tidyverse)
library(lubridate)
library(magrittr)
library(digest)
library(magrittr)


truncate_new_tables <- TRUE
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

#set order to cycle through tables with primary keys used as foreign keys first
old_table_names_foreign <- c(ow_old, gage_old, radar_old, con_phase_lookup_old, est_high_flow_efficiency_lookup_old, inventory_sensors_old,long_term_lookup_old, research_lookup_old, field_test_priority_lookup_old, surface_type_lookup_old, request_by_lookup_old, special_investigation_lookup_old, srt_type_lookup_old, sensor_issue_lookup_old, sensor_model_lookup_old, sensor_status_lookup_old, porous_pave_old, draindown_assessment_lookup_old, observed_simulated_lookup_old, snapshot_old)

#old tables without primary keys used as foreign keys
old_table_names_other <- c("public.accessdb", "public.baro_rawfile", "public.baro_rawfolder", "public.class_asset_surface", "public.gage_loc", "public.radarcell_loc", "public.radarcell_rawfile", "public.smp_gage", "public.smp_loc", "public.smp_radarcell", "public.baro", "public.rainfall_gage_event", "public.rainfall_gage_raw", "public.gw_depthdata_raw", "public.ow_leveldata_raw", "public.rainfall_radarcell_event", "public.rainfall_radarcell_raw", "fieldwork.capture_efficiency", "public.custom_project_names", "fieldwork.deployment", "fieldwork.future_capture_efficiency", "fieldwork.future_deployment", "fieldwork.future_inlet_conveyance", "fieldwork.future_porous_pavement", "fieldwork.future_special_investigation", "fieldwork.future_srt", "fieldwork.gswi_conveyance_subtype_lookup", "fieldwork.inlet_conveyance", "fieldwork.inventory_sensors", "fieldwork.monitoring_deny_list", "fieldwork.ow_prefixes", "public.ow_sumpdepth_default", "public.ow_sumpdepth_intermediate", "fieldwork.porous_pavement_maintenance", "fieldwork.porous_pavement_results", "fieldwork.site_name_lookup", "fieldwork.special_investigation", "fieldwork.srt", "fieldwork.well_measurements", "public.performance_error_lookup", "performance.eventdepth_bin_lookup", "performance.relative_eventdepth_bin_lookup", "public.snapshot_metadata")

#combine so that script cycles through tables in correct order
old_table_names <- c(old_table_names_foreign, old_table_names_other)


#Read parent foreign key tables from PG12
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


#set order to cycle through tables with primary keys used as foreign keys first
new_table_names_foreign <- c(ow_new, gage_new, radar_new, con_phase_lookup_new, est_high_flow_efficiency_lookup_new, inventory_sensors_new, long_term_lookup_new, research_lookup_new, field_test_priority_lookup_new, surface_type_lookup_new, requested_by_lookup_new, special_investigation_lookup_new, srt_type_lookup_new, sensor_issue_lookup_new, sensor_model_lookup_new, sensor_status_lookup_new, porous_pavement_new, draindown_assessment_lookup_new, observed_simulated_lookup_new, snapshot_new) 

#new tables without primary keys used as foreign keys
new_table_names_other <- c("admin.accessdb", "admin.baro_rawfile", "admin.baro_rawfolder", "admin.class_asset_surface", "admin.gage_loc", "admin.radar_loc", "admin.radar_rawfile", "admin.smp_gage", "admin.smp_loc", "admin.smp_radar", "data.baro", "data.gage_event", "data.gage_rain", "data.gw_depthdata_raw", "data.ow_leveldata_raw", "data.radar_event", "data.radar_rain", "fieldwork.capture_efficiency", "fieldwork.custom_project_names", "fieldwork.deployment", "fieldwork.future_capture_efficiency", "fieldwork.future_deployment", "fieldwork.future_inlet_conveyance", "fieldwork.future_porous_pavement", "fieldwork.future_special_investigation", "fieldwork.future_srt", "fieldwork.gswi_conveyance_subtype_lookup", "fieldwork.inlet_conveyance", "fieldwork.inventory_sensors", "fieldwork.monitoring_deny_list", "fieldwork.ow_prefixes", "fieldwork.ow_sumpdepth_default", "fieldwork.ow_sumpdepth_intermediate", "fieldwork.porous_pavement_maintenance", "fieldwork.porous_pavement_results", "fieldwork.site_name_lookup", "fieldwork.special_investigation", "fieldwork.srt", "fieldwork.well_measurements", "metrics.error_lookup", "metrics.eventdepth_bin_lookup", "metrics.relative_eventdepth_bin_lookup", "metrics.snapshot_metadata")

#combine so that script cycles through tables in correct order
new_table_names <- c(new_table_names_foreign, new_table_names_other)


#### Functions for querying (some of these were more useful  when using lapply)

#query data functions
pg9.query <- function(table){
  dbGetQuery(mars_9,paste0("SELECT * FROM ",table))
}
pg12.query <- function(table){
  dbGetQuery(mars_12,paste0("SELECT * FROM ",table))
}

#query data type function
pg9.data.type.query <- function(table){
  schema_table <- stringr::str_split_fixed(table, pattern = "\\.", n = 2)
  data_type_query_string <- paste0("SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = '", schema_table[1], "' AND TABLE_NAME = '",schema_table[2],"'")
  dbGetQuery(mars_9,data_type_query_string)
}

pg12.data.type.query <- function(table){
  schema_table <- stringr::str_split_fixed(table, pattern = "\\.", n = 2)
  data_type_query_string <- paste0("SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = '", schema_table[1], "' AND TABLE_NAME = '",schema_table[2],"'")
  dbGetQuery(mars_12,data_type_query_string)
}  

#Hash functions
hash.table <-function(table){
  data.frame(uid = table[,1], hash = apply(table, 1, digest))
}

no.uid.hash.table <- function(table){
  uid_table <- table[,1]  #grab uids
  if(ncol(table) > 1){
    no_uid_table <- as.data.frame(table[,2:ncol(table)])  #remove uids 
    no_uid_table_hash <- data.frame(no_uid_hash = apply(no_uid_table, 1, digest))  #hash table without uids
    data.frame(uid = uid_table, no_uid_hash = no_uid_table_hash)
  }
}


#Query builder functions
alter.query.fx <- function(names,values,data_types){
  x = ""
  # values <- as.data.frame(lapply(values,function(x){if(is.character(x)) paste0("'",x,"'") else x}))
  for(k in 1:length(values)){
    x <- paste0(x,names[k]," = '", values[,k],"'::",data_types[k])
    if(k < length(values)){ x <- paste0(x,", ")}
  }
  x <- gsub("'NA'","NULL",x)
  x <- gsub("\\'(\\d+)\\'","\\1",x)
  return(x)
}

append.query.fx <- function(values,data_types){
  x = "("
  # values <- as.data.frame(lapply(values,function(x){if(is.character(x)) paste0("'",x,"'") else x}))
  for(k in 1:length(values)){
    x <- paste0(x,"'", values[,k],"'::",data_types[k])
    if(k < length(values)){ x <- paste0(x,", ")}
  }
  x <- gsub("'NA'","NULL",x)
  x <- gsub("\\'(\\d+)\\'","\\1",x)
  x <- paste0(x,")")
  return(x)
}

#Define the "not in" operator for filtering records
`%!in%` <- negate(`%in%`)

#Function to pull uid name as a variable for dplyr::filter
# uid.pull <- function(table, matching_vector, match_type = 0){
#   if(match_type == 0){
#   x <- dplyr::filter(table, !!as.name(colnames(table)[1]) %in% matching_vector)
#   return(x)
#   } if (match_type == 1){
#   x <- dplyr::filter(table, !!as.name(colnames(table)[1]) %in% matching_vector)
#   return(x)
#   } else {
#     print("Invalid match type specified. Specify 0 to keep existing uid's in match_vector or 1 to remove uid's in match_vector.")
#   }
# }

#initialize delete records list
delete_records_list <- list()

#### Start the big loop for all tables
for(h in 1:length(new_table_names)){
  
  #query data tables
  old_data <- pg9.query(old_table_names[h])
  new_data <- pg12.query(new_table_names[h])
  
  
  #query data type for hard casting
  old_data_types <- pg9.data.type.query(old_table_names[h]) %>% unlist %>% as.vector
  new_data_types <- pg12.data.type.query(new_table_names[h]) %>% unlist %>% as.vector
  

  #hash tables
  old_hash <- hash.table(old_data) 
  new_hash <- hash.table(new_data)
  
  if(ncol(old_data) > 1){
    old_hash_no_uid <- no.uid.hash.table(old_data)
    new_hash_no_uid <- no.uid.hash.table(new_data)
    
    #compare tables to create three groups of records: records to append, records to alter, records to delete
    
    #list of records not matching
    old2new <- anti_join(old_hash, new_hash, by = "hash")
    new2old <- anti_join(new_hash, old_hash, by = "hash")
    
    #records not matching with data
    diff_records_old2new <- dplyr::filter(old_data, !!as.name(colnames(old_data)[1]) %in% old2new$uid)
    diff_records_new2old <- dplyr::filter(new_data, !!as.name(colnames(new_data)[1]) %in% new2old$uid)
    
    
    #find altered records
    altered_records_list <- dplyr::left_join(old_hash_no_uid, new_hash_no_uid, by = "no_uid_hash") %>%
      dplyr::filter(uid.x != uid.y) %>%
      dplyr::rename(uid_old = uid.x, uid_new = uid.y)
    #altered record complete with data
    altered_records <- dplyr::filter(old_data, !!as.name(colnames(old_data)[1]) %in% altered_records_list$uid_old)
    
    #run query to alter records
    if(seriously == TRUE& nrow(altered_records > 0)){
      altered_col_names <- colnames(altered_records)
      uid_name <- altered_col_names[1]
      uid_list <- altered_records_list$uid_new
      for(i in 1:length(uid_list)){
        x <- alter.query.fx(altered_col_names,altered_records[i,],new_data_types)
        alt_query <- paste0("UPDATE ",new_table_names[h]," SET ",x, " WHERE ",uid_name," = ",uid_list[i],";")
        rs <- dbSendQuery(mars_12, alt_query)
        dbClearResult(rs)
      }
    }
    
    #find records to append
    append_records <- dplyr::filter(old_data, !!as.name(colnames(old_data)[1]) %in% diff_records_old2new[1])
    
    #append records
    if(seriously == TRUE & nrow(append_records > 0)){
      append_col_names <- colnames(append_records)
      uid_name <- append_col_names[1]
      uid_list <- append_records[,1]
      
      for(i in 1:length(uid_list)){
        x <- append.query.fx(append_records[,i],new_data_types)
        append_query <- paste0("INSERT INTO ", new_table_names[h]," VALUES ",x)
        rs <- dbSendQuery(mars_12, append_query)
        dbClearResult(rs)
      }
    }
    
    #find records to delete
    delete_records <- dplyr::filter(diff_records_new2old, !!as.name(colnames(diff_records_old2new)[1]) %!in% diff_records_old2new$ow_uid)
    
    #save to a list to inspect rather than delete completely due to CASCADE/DELETE issues
    delete_records_list[[h]] <- delete_records
    names(delete_records_list)[h] <- new_table_names[h]
    
    

    #report results
    print(paste0("Loop complete for ",new_table_names[h],". ",nrow(append_records)," record(s) added, ",nrow(altered_records)," record(s) altered, and ",nrow(delete_records), " record(s) to be deleted."))
    #clear space
    remove(old_data, new_data, old_hash, new_hash, old_hash_no_uid, new_hash_no_uid,
           old2new, new2old, altered_records, altered_records_list, append_records,
           delete_records, uid_list, uid_name)

  }
}


#### Write delete list to file


#### Disconnect from databases
dbDisconnect(mars_9)
dbDisconnect(mars_12)
