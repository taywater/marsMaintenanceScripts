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
  
  
  #1.3 major data tables ----
    
    # # a.	baro
    # old_baro <- dbGetQuery(mars_testing, "select * from public.baro")
    # 
    # dbWriteTable(mars_data, DBI::SQL("data.baro"), old_baro, append = TRUE)
    # 
    # # b.	ow_leveldata_raw
    # old_ow_leveldata_raw <- dbGetQuery(mars_testing, "select * from ow_leveldata_raw")
    # 
    # dbWriteTable(mars_data, DBI::SQL("data.ow_leveldata_raw"), old_ow_leveldata_raw, append = TRUE)
    # 
    # # c.	gw_depthdata_raw
    # old_gw_depthdata_raw <- dbGetQuery(mars_testing, "select * from gw_depthdata_raw")
    # 
    # dbWriteTable(mars_data, DBI::SQL("data.gw_depthdata_raw"), old_gw_depthdata_raw, append = TRUE)
    # 
    # # d.	rainfall_gage_raw, as gage_rain
    # old_gage_rain <- dbGetQuery(mars_testing, "select * from rainfall_gage_raw") 
    # 
    # old_gage_rain <- old_gage_rain %>% rename(gage_rain_uid = rainfall_gage_raw_uid)
    # 
    # dbWriteTable(mars_data, DBI::SQL("data.rainfall_gage_raw"), old_gage_rain, append = TRUE)
    # 
    # # e.	rainfall_gage_event, as gage_event
    # old_gage_event <- dbGetQuery(mars_testing, "select * from rainfall_gage_event") 
    # 
    # old_gage_event <- old_gage_event %>% rename(gage_event_uid = rainfall_gage_event_uid)
    # 
    # dbWriteTable(mars_data, DBI::SQL("data.rainfall_gage_event"), old_gage_event, append = TRUE)
    # 
    # # f.	rainfall_radarcell_raw, as radar_rain
    # old_radar_rain <- dbGetQuery(mars_testing, "select * from rainfall_radarcell_raw") 
    # 
    # old_radar_rain <- old_radar_rain %>% rename(radar_rain_uid = rainfall_radarcell_uid, radar_uid = radarcell_uid)
    # 
    # dbWriteTable(mars_data, DBI::SQL("data.rainfall_radarcell_raw"), old_radar_rain, append = TRUE)
    # 
    # # g.	rainfall_radarcell_event, as radar_event
    # old_radar_event <- dbGetQuery(mars_testing, "select * from rainfall_radarcell_event") 
    # 
    # old_radar_event <- old_radar_event %>% rename(radar_event_uid = rainfall_radarcell_event_uid, radar_uid = radarcell_uid)
    # 
    # dbWriteTable(mars_data, DBI::SQL("data.rainfall_radarcell_event"), old_radar_event, append = TRUE)
    
  #1.4 major fieldwork tables ----
    
    # a.	capture_efficiency
    old_cet <- dbGetQuery(mars_testing, "select * from fieldwork.capture_efficiency")
    
    dbWriteTable(mars_data, DBI::SQL("fieldwork.capture_efficiency"), old_cet, append = TRUE)
    
    # b.	deployment
    old_deployment <- dbGetQuery(mars_testing, "select * from fieldwork.deployment")
    #ERROR invensotry sensors uid fkey
    #need to write sensors first
    #ERROR ow_uid_fkey WHY
    
    updated_deployment <- old_deployment %>% right_join(new_fieldwork_ow, by = "ow_uid") %>% 
      dplyr::filter(!is.na(deployment_uid)) %>% 
      dplyr::select(1:15)
    
    #lost_deployment <- old_deployment %>% anti_join(updated_deployment, by = "ow_uid")
    
    #dbWriteTable(mars_data, DBI::SQL("fieldwork.deployment"), updated_deployment, append = TRUE)
    
    # c.	inlet_conveyance
    old_ict <- dbGetQuery(mars_testing, "select * from fieldwork.inlet_conveyance")
    
    #dbWriteTable(mars_data, DBI::SQL("fieldwork.inlet_conveyance"), old_ict, append = TRUE)
    
    # d.	inventory_sensors
    old_inv <- dbGetQuery(mars_testing, "select * from fieldwork.inventory_sensors")
    
    #dbWriteTable(mars_data, DBI::SQL("fieldwork.inventory_sensors"), old_inv, append = TRUE)
    
    # e.	ow_all, as ow WRITTEN IN 1.1
    
    # f.	porous_pavement
    old_pp <- dbGetQuery(mars_testing, "select * from fieldwork.porous_pavement")
    
    # dbWriteTable(mars_data, DBI::SQL("fieldwork.porous_pavement"), old_pp, append = TRUE)
    
    # g.	porous_pavement_maintenance
    old_ppm <- dbGetQuery(mars_testing, "select * from fieldwork.porous_pavement_maintenance")
    
    # dbWriteTable(mars_data, DBI::SQL("fieldwork.porous_pavement_maintenance"), old_ppm, append = TRUE)
    
    # h.	porous_pavement_results
    old_ppr <- dbGetQuery(mars_testing, "select * from fieldwork.porous_pavement_results") %>% 
      mutate(across(where(is.numeric),  round, 4))
    
    #numeric field overflow
    dbWriteTable(mars_data, DBI::SQL("fieldwork.porous_pavement_results"), old_ppr, append = TRUE)
    
    # i.	special_investigation
    old_si <- dbGetQuery(mars_testing, "select * from fieldwork.special_investigation")
    #error - system validity - dropped
    # dbWriteTable(mars_data, DBI::SQL("fieldwork.special_investigation"), old_si, append = TRUE)
    
    # j.	srt
    old_srt <- dbGetQuery(mars_testing, "select * from fieldwork.srt")
    
    # dbWriteTable(mars_data, DBI::SQL("fieldwork.srt"), old_srt, append = TRUE)
    
    # k.	well_measurements
    old_wm <- dbGetQuery(mars_testing, "select * from fieldwork.well_measurements")
    #error - ow_Uid_fkey
    
    updated_wm <- old_wm %>% right_join(new_fieldwork_ow, by = "ow_uid") %>% 
      dplyr::filter(!is.na(well_measurements_uid)) %>% 
      dplyr::select(1:11)
    
    lost_wm <- old_wm %>% anti_join(updated_wm, by = "ow_uid")
    
    # dbWriteTable(mars_data, DBI::SQL("fieldwork.well_measurements"), updated_wm, append = TRUE)
    
    
    # l.	future_capture_efficiency
    old_f_cet <- dbGetQuery(mars_testing, "select * from fieldwork.future_capture_efficiency")
    #error component validity #dropped constraint
    #dbWriteTable(mars_data, DBI::SQL("fieldwork.future_capture_efficiency"), old_f_cet, append = TRUE)
    
    # m.	future_deployment
    old_f_deployment <- dbGetQuery(mars_testing, "select * from fieldwork.future_deployment")
    
    # dbWriteTable(mars_data, DBI::SQL("fieldwork.future_deployment"), old_f_deployment, append = TRUE)
    
    # n.	future_inlet_conveyance
    old_f_ict <- dbGetQuery(mars_testing, "select * from fieldwork.future_inlet_conveyance")
    
     dbWriteTable(mars_data, DBI::SQL("fieldwork.future_inlet_conveyance"), old_f_ict, append = TRUE)
    
    # o.	future_porous_pavement
    old_f_pp <- dbGetQuery(mars_testing, "select * from fieldwork.future_porous_pavement")
    #this is empty
    # dbWriteTable(mars_data, DBI::SQL("fieldwork.future_porous_pavement"), old_f_pp, append = TRUE)
    
    # p.	future_srt
    old_f_srt <- dbGetQuery(mars_testing, "select * from fieldwork.future_srt")
    
    # dbWriteTable(mars_data, DBI::SQL("fieldwork.future_srt"), old_f_srt, append = TRUE)
    
    # q.	future_special_investigations
    old_f_si <- dbGetQuery(mars_testing, "select * from fieldwork.future_special_investigation")
    #this is empty
    # dbWriteTable(mars_data, DBI::SQL("fieldwork.future_special_investigation"), old_f_si, append = TRUE)
    
    # r.	custom_project_names
    old_cpn <- dbGetQuery(mars_testing, "select * from public.custom_project_names")
    
    # dbWriteTable(mars_data, DBI::SQL("fieldwork.custom_project_names"), old_cpn, append = TRUE)
    
  #1.5 major metrics tables ----
    
    # a.	performance_draindown_radarcell, as draindown
    old_draindown <- dbGetQuery(mars_testing, "select * from performance_draindown_radarcell")
    
    old_draindown <- old_draindown %>% dplyr::rename(draindown_uid = performance_draindown_radarcell_uid, 
                                                     draindown_assessment_lookup_uid = performance_draindown_assessment_lookup_uid, 
                                                     radar_event_uid = rainfall_radarcell_event_uid)
    
    # dbWriteTable(mars_data, DBI::SQL("metrics.draindown"), old_draindown, append = TRUE)
    
    # b.	performance_infiltration_radarcell, as infiltration
    old_infiltration <- dbGetQuery(mars_testing, "select * from performance_infiltration_radarcell")
    
    old_infiltration <- old_infiltration %>% dplyr::rename(infiltration_uid = performance_infiltration_radarcell_uid, 
                                                           radar_event_uid = rainfall_radarcell_event_uid)
    
    # dbWriteTable(mars_data, DBI::SQL("metrics.infiltration"), old_infiltration, append = TRUE)
    
    # c.	performance_overtopping_radarcell, as overtopping
    old_overtopping <- dbGetQuery(mars_testing, "select * from performance_overtopping_radarcell")
    
    old_overtopping <- old_overtopping %>% dplyr::rename(overtopping_uid = performance_overtopping_radarcell_uid,
                                                         radar_event_uid = rainfall_radarcell_event_uid)
    
    # dbWriteTable(mars_data, DBI::SQL("metrics.overtopping"), old_overtopping, append = TRUE)
    
    # d.	performance_percentstorage_radarcell, as percentstorage
    old_percentstorage <- dbGetQuery(mars_testing, "select * from performance_percentstorage_radarcell")
    
    old_percentstorage <- old_percentstorage %>% dplyr::rename(percentstorage_uid = performance_percentstorage_radarcell_uid,
                                                               radar_event_uid = rainfall_radarcell_event_uid)
    
    # dbWriteTable(mars_data, DBI::SQL("metrics.percentstorage"), old_percentstorage, append = TRUE)
    
    # e.	snapshot WRITE THIS FIRST (after OW)
    old_snapshot <- dbGetQuery(mars_testing, "select * from snapshot") %>% 
      mutate(across(where(is.numeric),  round, 4))
    
    #dbWriteTable(mars_data, DBI::SQL("metrics.snapshot"), old_snapshot, append = TRUE)
    
    #write.csv(old_snapshot, "old_snapshot.csv")
    
    # f.	snapshot_metadata
    old_snapshot_metadata <- dbGetQuery(mars_testing, "select * from snapshot_metadata")
    
    #dbWriteTable(mars_data, DBI::SQL("metrics.snapshot_metadata"), old_snapshot_metadata, append = TRUE)
    
  #1.6 major admin tables ----
    
    # a.	accessdb
    old_accessdb <- dbGetQuery(mars_testing, "select * from accessdb")
    
    # dbWriteTable(mars_data, DBI::SQL("admin.accessdb"), old_accessdb, append = TRUE)
    
    # b.	baro_rawfile
    old_baro_rawfile <- dbGetQuery(mars_testing, "select * from baro_rawfile")
    
    # dbWriteTable(mars_data, DBI::SQL("admin.baro_rawfile"), old_baro_rawfile, append = TRUE)
    
    # c.	baro_rawfolder
    old_baro_rawfolder <- dbGetQuery(mars_testing, "select * from baro_rawfolder")
    
    # dbWriteTable(mars_data, DBI::SQL("admin.baro_rawfolder"), old_baro_rawfolder, append = TRUE)
    
    # d.	gage
    old_gage <- dbGetQuery(mars_testing, "select * from gage")
    
    # dbWriteTable(mars_data, DBI::SQL("admin.gage"), old_gage, append = TRUE)
    
    # e.	gage_loc
    old_gage_loc <- dbGetQuery(mars_testing, "select * from gage_loc")
    
    # dbWriteTable(mars_data, DBI::SQL("admin.gage_loc"), old_gage_loc, append = TRUE)
    
    # f.	radarcell, as radar
    old_radar <- dbGetQuery(mars_testing, "select * from radarcell")
    
    old_radar <- old_radar %>% dplyr::rename(radar_uid = radarcell_uid)
    
    # dbWriteTable(mars_data, DBI::SQL("admin.radar"), old_radar, append = TRUE)
    
    # g.	radarcell_loc, as radar_loc
    old_radar_loc <- dbGetQuery(mars_testing, "select * from radarcell_loc")
    
    old_radar_loc <- old_radar_loc %>% dplyr::rename(radar_loc_uid = radarcell_loc_uid, radar_uid = radarcell_uid)
    
    # dbWriteTable(mars_data, DBI::SQL("admin.radar_loc"), old_radar_loc, append = TRUE)
    
    # h.	radarcell_rawfile, as radar_rawfile
    old_radar_rawfile <- dbGetQuery(mars_testing, "select * from radarcell_rawfile") 
    
    old_radar_rawfile <- old_radar_rawfile %>% dplyr::rename(radar_rawfile_uid = radarcell_rawfile_uid)
    
    # dbWriteTable(mars_data, DBI::SQL("admin.radar_rawfile"), old_radar_rawfile, append = TRUE)
    
    # i.	smp_gage
    old_smp_gage <- dbGetQuery(mars_testing, "select * from smp_gage")
    
    assets <- dbGetQuery(mars_data, "select * from external.assets where component_id is null")
    
    updated_smp_gage <- old_smp_gage %>% right_join(assets)  %>% 
      dplyr::select(smp_gage_uid, smp_id, gage_uid) %>% 
      dplyr::filter(complete.cases(.)) %>% 
      distinct()
    
    # dbWriteTable(mars_data, DBI::SQL("admin.smp_gage"), updated_smp_gage, append = TRUE)
    
    # j.	smp_loc
    old_smp_loc <- dbGetQuery(mars_testing, "select * from smp_loc")
    
    updated_smp_loc <- old_smp_loc %>% right_join(assets)  %>% 
      dplyr::select(smp_loc_uid, smp_id, lon_wgs84, lat_wgs84) %>% 
      dplyr::filter(complete.cases(.)) %>% 
      distinct()
    
    # dbWriteTable(mars_data, DBI::SQL("admin.smp_loc"), updated_smp_loc, append = TRUE)
    
    # k.	smp_radarcell, as smp_radar
    old_smp_radar <- dbGetQuery(mars_testing, "select * from smp_radarcell")
    
    old_smp_radar <- old_smp_radar %>% dplyr::rename(smp_radar_uid = smp_radarcell_uid, radar_uid = radarcell_uid)
    
    updated_smp_radar <- old_smp_radar %>% right_join(assets)  %>% 
      dplyr::select(smp_radar_uid, radar_uid, smp_id) %>% 
      dplyr::filter(complete.cases(.)) %>% 
      distinct()
    
    # dbWriteTable(mars_data, DBI::SQL("admin.smp_radar"), updated_smp_radar, append = TRUE)
    
    # l.	monitoring_deny_list
    old_deny <- dbGetQuery(mars_testing, "select * from fieldwork.monitoring_deny_list")

    # updated_deny <- old_deny %>% right_join(assets)  %>% 
    #   dplyr::select(monitoring_deny_list_uid, smp_id, reason) %>% 
    #   dplyr::filter(complete.cases(.)) %>% 
    #   distinct()
    
    dbWriteTable(mars_data, DBI::SQL("admin.monitoring_deny_list"), old_deny, append = TRUE)
    
        
  
  
  