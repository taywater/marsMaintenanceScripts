#Note: much of this code is predicated on the assumption of the primary key of a
#table is stored within the first column of that table. Any alteration to that
#assumption would render this code effectively useless. This is something to
#eventually correct, but seems outside the scope of the task.


library(odbc)
library(tidyverse)
library(lubridate)
library(magrittr)
library(digest)
lb


  truncate_new_tables <- FALSE
  seriously <- TRUE

  
  #connect to testing database-
  mars_9 <- dbConnect(odbc(), "mars_testing")
  
  #testing mode
  mars_12 <- dbConnect(odbc(), "mars_brian")
  #write mode
  #mars_12 <- dbConnect(odbc(), "mars_data")
  
  cons <- list(mars_9,mars_12)

#Writing data tables from PG9 to PG12
#Read parent foreign key tables from PG9
  ow_old <- "fieldwork.ow_all"
  gage_old <- "public.gage"
  radar_old <- "public.radarcell"
  con_phase_lookup_old <- "fieldwork.con_phase_lookup"
  est_high_flow_efficiency_lookup_old <- "fieldwork.est_high_flow_efficiency_lookup"
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
  old_table_names <- c(ow_old, gage_old, radar_old, con_phase_lookup_old, est_high_flow_efficiency_lookup_old, long_term_lookup_old, research_lookup_old, field_test_priority_lookup_old, surface_type_lookup_old, request_by_lookup_old, special_investigation_lookup_old, srt_type_lookup_old, sensor_issue_lookup_old, sensor_model_lookup_old, sensor_status_lookup_old, porous_pave_old, draindown_assessment_lookup_old, observed_simulated_lookup_old, snapshot_old)
  
#Read parent foreign key tables from PG9  
  ow_new <- "fieldwork.ow"
  gage_new <- "admin.gage"
  radar_new <- "admin.radar"
  con_phase_lookup_new <- "fieldwork.con_phase_lookup"
  est_high_flow_efficiency_lookup_new <- "fieldwork.est_high_flow_efficiency_lookup"
  # inventory_sensors_new <- "fieldwork.inventory_sensors"
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
  # new_table_names <- c(ow_new, gage_new, radar_new, con_phase_lookup_new, est_high_flow_efficiency_lookup_new, inventory_sensors_new, long_term_lookup_new, research_lookup_new, field_test_priority_lookup_new, surface_type_lookup_new, requested_by_lookup_new, special_investigation_lookup_new, srt_type_lookup_new, sensor_issue_lookup_new, sensor_model_lookup_new, sensor_status_lookup_new, porous_pavement_new, draindown_assessment_lookup_new, error_lookup_new, observed_simulated_lookup_new, snapshot_new)
  new_table_names <- c(ow_new, gage_new, radar_new, con_phase_lookup_new, est_high_flow_efficiency_lookup_new, long_term_lookup_new, research_lookup_new, field_test_priority_lookup_new, surface_type_lookup_new, requested_by_lookup_new, special_investigation_lookup_new, srt_type_lookup_new, sensor_issue_lookup_new, sensor_model_lookup_new, sensor_status_lookup_new, porous_pavement_new, draindown_assessment_lookup_new, observed_simulated_lookup_new, snapshot_new) 
  
#Append new data from PG9 to corresponding PG12 tables
#pull data
  
#query function
  pg9_query <- function(table){
    dbGetQuery(mars_9,paste0("SELECT * FROM ",table))
  }
  pg12_query <- function(table){
    dbGetQuery(mars_12,paste0("SELECT * FROM ",table))
  }
  
#query data
old_tables <- lapply(old_table_names,pg9_query)
new_tables <- lapply(new_table_names, pg12_query)

#add names
names(old_tables) <- old_table_names
names(new_tables) <- new_table_hashes
  
#create hash function
hash_table <- function(table){
  data.frame(uid = table[,1], hash = apply(table, 1, digest))
  }  

#apply hash function across old and new tables 
lapply(old_tables,hash_table)
old_table_hashes <- lapply(old_tables,hash_table)
new_table_hashes <- lapply(new_tables,hash_table)



#record entries altered between tables
altered_entries <- list()
for(i in 1:length(old_table_hashes)){
  # altered_entries[[i]] <- anti_join(old_table_hashes[[i]],new_table_hashes[[i]], by = "hash")
  x <- anti_join(old_table_hashes[[i]],new_table_hashes[[i]], by = "hash")
  y <- dplyr::filter(old_tables[[i]], !!as.name(colnames(old_tables[[i]])[1]) %in% x$uid)
  altered_entries[[i]] <- y
  }


#Define "not in" operator for filtering
`%!in%` <- Negate(`%in%`)

#Create lists for 3 queries: entries to delete, alter, and append
delete_tables <- list()
alter_tables <- list()
append_tables <- list()

 for(i in 1:length(new_tables)){

   #remove entries with uid's in the altered table
   x <- dplyr::filter(new_tables[[i]], !!as.name(colnames(new_tables[[i]])[1]) %!in% altered_entries[[i]][[1]])

   #Create delete table using negation
   delete_tables[[i]] <- dplyr::filter(new_tables[[i]],!!as.name(colnames(new_tables[[i]])[1]) %!in% old_tables[[i]][[1]])

   #remove entries to be deleted from x...
   x %<>% dplyr::filter(!!as.name(colnames(x)[1]) %!in% y[[1]])

   #Find altered entries
   y <- dplyr::filter(new_tables[[i]], !!as.name(colnames(new_tables[[i]])[1]) %in% altered_entries[[i]][[1]])
   alter_tables[[i]] <- y

   #Find new entries to append
   z <- dplyr::filter(old_tables[[i]], !!as.name(colnames(old_tables[[i]])[1]) %in% altered_entries[[i]][[1]])
   append_tables[[i]]  <- z %>% dplyr::filter(!!as.name(colnames(z)[1]) %!in% new_tables[[i]][[1]])

   }

# pass tables to respective queries in pg12
# order of: delete, alter, append
 for(i in 1:length(delete_tables)){
   if(seriously == TRUE & nrow(delete_tables[[i]]) > 0){
     uid_name <- colnames(new_tables[[i]])[1]
     uid_del_list <- paste(delete_tables[[i]][,1], collapse = ", ")
     del_query <- paste0("DELETE * FROM ",new_table_names[i]," WHERE ", uid_name, " IN (", uid_del_list,")")
     dbGetQuery(mars_12, del_query)
   }
 }

alter_query_fx <- function(names,values){
  x = ""
  for(k in 1:length(values)){
    x <- paste0(x,names[k]," = '", values[k],"'")
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
     for(j in 1:length(uid_upd_list)){
       x <- alter_query_fx(col_names,alter_tables[[i]][j,])
       alt_query <- paste0("UPDATE ",new_table_names[i]," SET ",x, " WHERE ",uid_name," = ",uid_upd_list[j],";")
       dbSendStatement(mars_12, alt_query)
     }
   }
 }

for(i in 1:length(append_tables)){
  if(seriously == TRUE & nrow(append_tables[[i]] > 0)){
    
  }
}

# for(i in 1:length(altered_entries)){
# #delete query
#   if(seriously == TRUE & nrow(altered_entries[[i]]) > 0){
#     #delete entries    
#     uid_name <- colnames(new_tables[[i]])[1]
#     uid_del_list <- paste(altered_entries[[i]][,1], collapse = ", ")
#     del_query <- paste0("DELETE * FROM ",new_table_names[i]," WHERE ", uid_name, " IN (", uid_del_list,")")
#     dbGetQuery(mars_12, del_query)
#     #write entries    
#     for(j in 1:nrow(altered_entries[[i]])){
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

dbDisconnect(mars_9)
dbDisconnect(mars_12)


