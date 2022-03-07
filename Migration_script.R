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

#set order to cycle through tables with primary keys used as foreign keys first
old_table_names_foreign <- c(ow_old, gage_old, radar_old, con_phase_lookup_old, est_high_flow_efficiency_lookup_old, inventory_sensors_old,long_term_lookup_old, research_lookup_old, field_test_priority_lookup_old, surface_type_lookup_old, request_by_lookup_old, special_investigation_lookup_old, srt_type_lookup_old, sensor_issue_lookup_old, sensor_model_lookup_old, sensor_status_lookup_old, porous_pave_old, draindown_assessment_lookup_old, observed_simulated_lookup_old, snapshot_old)

#old tables without primary keys used as foreign keys
ol_table_names_other <- c("public.accessdb", "public.baro_rawfile", "public.baro_rawfolder", "public.class_asset_surface", "public.gage_loc", "public.radarcell_loc", "public.radarcell_rawfile", "public.smp_gage", "public.smp_loc", "public.smp_radarcell", "public.baro", "public.rainfall_gage_event", "public.rainfall_gage_raw", "public.gw_depthdata_raw", "public.ow_leveldata_raw", "public.rainfall_radarcell_event", "public.rainfall_radarcell_raw", "fieldwork.capture_efficiency", "public.custom_project_names", "fieldwork.deployment", "fieldwork.future_capture_efficiency", "fieldwork.future_deployment", "fieldwork.future_inlet_conveyance", "fieldwork.future_porous_pavement", "fieldwork.future_special_investigation", "fieldwork.future_srt", "fieldwork.gswi_conveyance_subtype_lookup", "fieldwork.inlet_conveyance", "fieldwork.inventory_sensors", "fieldwork.monitoring_deny_list", "fieldwork.ow_prefixes", "public.ow_sumpdepth_default", "public.ow_sumpdepth_intermediate", "fieldwork.porous_pavement_maintenance", "fieldwork.porous_pavement_results", "fieldwork.site_name_lookup", "fieldwork.special_investigation", "fieldwork.srt", "fieldwork.well_measurements", "public.performance_error_lookup", "performance.eventdepth_bin_lookup", "performance.relative_eventdepth_bin_lookup", "public.snapshot_metadata")

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