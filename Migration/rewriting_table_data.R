#querying old tables from PG9 and writing them to PG12 

#starting with pg9 fieldwork.ow_all -> pg12 fieldwork.ow

#0.0 set up -----
  
  #0.1 libraries ----
  library(odbc)
  library(tidyverse)
  
  #0.2 mars testing connection (OLD) ----
  mars_testing <- dbConnect(odbc(), "mars_testing")
  
  dbListTables(mars_testing)
  
  #0.3 mars data connnection (NEW) -----
  mars_data <- dbConnect(odbc(), "mars_data")
  
  dbListTables(mars_data)
  
#1.0 querying, modifying, and writing tables ----
  
  #1.1 fieldwork.ow ----
  #this needs to come first so we can add foreign constraints to other tables regarding ow_uid 
  old_fieldwork_ow <- dbGetQuery(mars_testing, "select * from fieldwork.ow_all")


  #don't forget to restart sequence at some point! 
  # dbWriteTable(mars_data,  DBI::SQL("fieldwork.ow"), old_fieldwork_ow, append = TRUE)

  #check that it wrote successfully 
  new_fieldwork_ow <- dbGetQuery(mars_data, "select * from fieldwork.ow")
  
  #1.2 Lookup tables! ----
  
  #con phase
  old_con_phase <- dbGetQuery(mars_testing, "select * from fieldwork.con_phase_lookup")

  # dbWriteTable(mars_data, DBI::SQL("fieldwork.con_phase_lookup"), old_con_phase, append = TRUE)
  
  #est high flow efficiency 
  old_est_high_flow_efficiency <- dbGetQuery(mars_testing, "select * from fieldwork.est_high_flow_efficiency_lookup")
  
  # dbWriteTable(mars_data, DBI::SQL("fieldwork.est_high_flow_efficiency_lookup"), old_est_high_flow_efficiency, append = TRUE)
  
  #long term 
  old_long_term <- dbGetQuery(mars_testing, "select * from fieldwork.long_term_lookup")
  
  # dbWriteTable(mars_data, DBI::SQL("fieldwork.long_term_lookup"), old_long_term, append = TRUE)
  
  old_research_lookup <- dbGetQuery(mars_testing, "select * from fieldwork.research_lookup")
  
  # dbWriteTable(mars_data, DBI::SQL("fieldwork.research_lookup"), old_research_lookup, append = TRUE)
  
  #sensor issue
  old_sensor_issue_lookup <- dbGetQuery(mars_testing, "select * from fieldwork.sensor_issue_lookup")
  
  # dbWriteTable(mars_data, DBI::SQL("fieldwork.sensor_issue_lookup"), old_sensor_issue_lookup, append = TRUE)
  
  #sensor model 
  old_sensor_model_lookup <- dbGetQuery(mars_testing, "select * from fieldwork.sensor_model_lookup")
  
  # dbWriteTable(mars_data, DBI::SQL("fieldwork.sensor_model_lookup"), old_sensor_model_lookup, append = TRUE)
  
  #sensor status 
  old_sensor_status_lookup <- dbGetQuery(mars_testing, "select * from fieldwork.sensor_status_lookup")
  
  # dbWriteTable(mars_data, DBI::SQL("fieldwork.sensor_status_lookup"), old_sensor_status_lookup, append = TRUE)
  
  #surface type
  old_surface_type_lookup <- dbGetQuery(mars_testing, "select * from fieldwork.surface_type_lookup")
  
  #dbWriteTable(mars_data, DBI::SQL("fieldwork.surface_type_lookup"), old_surface_type_lookup, append = TRUE)
  
  #requested by 
  old_requested_by_lookup <- dbGetQuery(mars_testing, "select * from fieldwork.requested_by_lookup")
  
  # dbWriteTable(mars_data, DBI::SQL("fieldwork.requested_by_lookup"), old_requested_by_lookup, append = TRUE)
  
  #srt type
  old_srt_type_lookup <- dbGetQuery(mars_testing, "select * from fieldwork.srt_type_lookup")
  
  # dbWriteTable(mars_data, DBI::SQL("fieldwork.srt_type_lookup"), old_srt_type_lookup, append = TRUE)
  
  #field test priority
  old_field_test_priority_lookup <- dbGetQuery(mars_testing, "select * from fieldwork.field_test_priority_lookup")
  
  # dbWriteTable(mars_data, DBI::SQL("fieldwork.field_test_priority_lookup"), old_field_test_priority_lookup, append = TRUE)
  
  #si
  old_special_investigation_lookup <- dbGetQuery(mars_testing, "select * from fieldwork.special_investigation_lookup")
  
  # dbWriteTable(mars_data, DBI::SQL("fieldwork.special_investigation_lookup"), old_special_investigation_lookup, append = TRUE)
  
  #obs sim
  old_observed_simulated_lookup <- dbGetQuery(mars_testing, "select * from observed_simulated_lookup")
  
  # dbWriteTable(mars_data, DBI::SQL("metrics.observed_simulated_lookup"), old_observed_simulated_lookup, append = TRUE)
  
  #draindown assessment
  old_draindown_assessment_lookup <- dbGetQuery(mars_testing, "select * from performance_draindown_assessment_lookup") %>% 
    rename(draindown_assessment_lookup_uid = performance_draindown_assessment_lookup_uid)
  
  # dbWriteTable(mars_data, DBI::SQL("metrics.draindown_assessment_lookup"), old_draindown_assessment_lookup, append = TRUE)
  
  #old error
  old_error_lookup <- dbGetQuery(mars_testing, "select * from performance_error_lookup")

  # dbWriteTable(mars_data, DBI::SQL("metrics.error_lookup"), old_error_lookup, append = TRUE)
  
  
  