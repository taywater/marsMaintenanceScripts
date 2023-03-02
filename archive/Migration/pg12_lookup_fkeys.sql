-- foreign keys from main tables to lookup tables 

--DATA
-- baro 
alter table data.baro
add constraint baro_rawfile_fkey FOREIGN KEY (baro_rawfile_uid)
        REFERENCES admin.baro_rawfile (baro_rawfile_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE NO ACTION;

-- gage_rain 
alter table data.gage_rain 
add constraint gage_uid_fkey FOREIGN KEY (gage_uid)
        REFERENCES admin.gage (gage_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE NO ACTION;

-- gage_event 
alter table data.gage_event
add constraint gage_uid_fkey FOREIGN KEY (gage_uid)
        REFERENCES admin.gage (gage_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE NO ACTION;

--rainfall_radarcell_event
alter table data.radar_event 
add constraint radar_uid_fkey FOREIGN KEY (radar_uid)
        REFERENCES admin.radar (radar_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE NO ACTION;

--FIELDWORK 
-- capture efficiency
alter table fieldwork.capture_efficiency
add constraint con_phase_lookup_uid_fky FOREIGN KEY (con_phase_lookup_uid)
        REFERENCES fieldwork.con_phase_lookup (con_phase_lookup_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT;


alter table fieldwork.capture_efficiency
add CONSTRAINT est_high_flow_efficiency_lookup_uid_fkey FOREIGN KEY (est_high_flow_efficiency_lookup_uid)
        REFERENCES fieldwork.est_high_flow_efficiency_lookup (est_high_flow_efficiency_lookup_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT; 

-- deployment 
alter table fieldwork.deployment 
add constraint inventory_sensors_uid_fkey FOREIGN KEY (inventory_sensors_uid)
        REFERENCES fieldwork.inventory_sensors (inventory_sensors_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE NO ACTION; 

alter table fieldwork.deployment
add CONSTRAINT long_term_lookup_uid_fkey FOREIGN KEY (long_term_lookup_uid)
        REFERENCES fieldwork.long_term_lookup (long_term_lookup_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT;

alter table fieldwork.deployment
add CONSTRAINT research_lookup_uid_fkey FOREIGN KEY (research_lookup_uid)
        REFERENCES fieldwork.research_lookup (research_lookup_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT;

-- inlet conveyance 
alter table fieldwork.inlet_conveyance
add constraint con_phase_lookup_uid_fky FOREIGN KEY (con_phase_lookup_uid)
        REFERENCES fieldwork.con_phase_lookup (con_phase_lookup_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT;

-- inventory sensors 
alter table fieldwork.inventory_sensors
add CONSTRAINT sensor_issue_lookup_uid_one_fkey FOREIGN KEY (sensor_issue_lookup_uid_one)
        REFERENCES fieldwork.sensor_issue_lookup (sensor_issue_lookup_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT;

alter table fieldwork.inventory_sensors
add CONSTRAINT sensor_issue_lookup_uid_two_fkey FOREIGN KEY (sensor_issue_lookup_uid_two)
        REFERENCES fieldwork.sensor_issue_lookup (sensor_issue_lookup_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT;

alter table fieldwork.inventory_sensors
add CONSTRAINT sensor_model_lookup_uid_fkey FOREIGN KEY (sensor_model_lookup_uid)
        REFERENCES fieldwork.sensor_model_lookup (sensor_model_lookup_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT;

alter table fieldwork.inventory_sensors
add CONSTRAINT sensor_status_lookup_uid_fkey FOREIGN KEY (sensor_status_lookup_uid)
        REFERENCES fieldwork.sensor_status_lookup (sensor_status_lookup_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT;

-- porous pavement
alter table fieldwork.porous_pavement
add constraint con_phase_lookup_uid_fky FOREIGN KEY (con_phase_lookup_uid)
        REFERENCES fieldwork.con_phase_lookup (con_phase_lookup_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT;

alter table fieldwork.porous_pavement
add constraint surface_type_lookup_uid_fkey FOREIGN KEY (surface_type_lookup_uid)
        REFERENCES fieldwork.surface_type_lookup (surface_type_lookup_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT;

-- porous_pavement_results
alter table fieldwork.porous_pavement_results
add CONSTRAINT porous_pavement_uid_fkey FOREIGN KEY (porous_pavement_uid)
        REFERENCES fieldwork.porous_pavement (porous_pavement_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT;

-- special_investigation
alter table fieldwork.special_investigation
add CONSTRAINT con_phase_lookup_uid_fky FOREIGN KEY (con_phase_lookup_uid)
        REFERENCES fieldwork.con_phase_lookup (con_phase_lookup_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT;

alter table fieldwork.special_investigation
add constraint requested_by_lookup_uid_fky FOREIGN KEY (requested_by_lookup_uid)
        REFERENCES fieldwork.requested_by_lookup (requested_by_lookup_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT;

alter table fieldwork.special_investigation
add constraint special_investigation_lookup_uid_fky FOREIGN KEY (special_investigation_lookup_uid)
        REFERENCES fieldwork.special_investigation_lookup (special_investigation_lookup_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT;

-- srt 
alter table fieldwork.srt 
add constraint con_phase_lookup_uid_fkey FOREIGN KEY (con_phase_lookup_uid)
        REFERENCES fieldwork.con_phase_lookup (con_phase_lookup_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT;

alter table fieldwork.srt 
add constraint srt_type_lookup_uid_fkey FOREIGN KEY (srt_type_lookup_uid)
        REFERENCES fieldwork.srt_type_lookup (srt_type_lookup_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT;

-- future_capture_efficiency
alter table fieldwork.future_capture_efficiency
add constraint con_phase_lookup_uid_fky FOREIGN KEY (con_phase_lookup_uid)
        REFERENCES fieldwork.con_phase_lookup (con_phase_lookup_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT; 

alter table fieldwork.future_capture_efficiency
add  CONSTRAINT field_test_priority_lookup_uid_fkey FOREIGN KEY (field_test_priority_lookup_uid)
        REFERENCES fieldwork.field_test_priority_lookup (field_test_priority_lookup_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT;

-- future_deployment
alter table fieldwork.future_deployment
add CONSTRAINT field_test_priority_lookup_uid_fkey FOREIGN KEY (field_test_priority_lookup_uid)
        REFERENCES fieldwork.field_test_priority_lookup (field_test_priority_lookup_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT;

alter table fieldwork.future_deployment
add CONSTRAINT inventory_sensors_uid_fkey FOREIGN KEY (inventory_sensors_uid)
        REFERENCES fieldwork.inventory_sensors (inventory_sensors_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT;

alter table fieldwork.future_deployment
add  CONSTRAINT long_term_lookup_uid_fkey FOREIGN KEY (long_term_lookup_uid)
        REFERENCES fieldwork.long_term_lookup (long_term_lookup_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT;

alter table fieldwork.future_deployment
add CONSTRAINT research_lookup_uid_fkey FOREIGN KEY (research_lookup_uid)
        REFERENCES fieldwork.research_lookup (research_lookup_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT;

-- future_inlet_conveyance
alter table fieldwork.future_inlet_conveyance
add CONSTRAINT con_phase_lookup_uid_fky FOREIGN KEY (con_phase_lookup_uid)
        REFERENCES fieldwork.con_phase_lookup (con_phase_lookup_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT;

alter table fieldwork.future_inlet_conveyance
add CONSTRAINT field_test_priority_lookup_uid_fkey FOREIGN KEY (field_test_priority_lookup_uid)
        REFERENCES fieldwork.field_test_priority_lookup (field_test_priority_lookup_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT;    

-- future_porous_pavement 
alter table fieldwork.future_porous_pavement
add CONSTRAINT con_phase_lookup_uid_fky FOREIGN KEY (con_phase_lookup_uid)
        REFERENCES fieldwork.con_phase_lookup (con_phase_lookup_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT;

alter table fieldwork.future_porous_pavement
add CONSTRAINT field_test_priority_lookup_uid_fkey FOREIGN KEY (field_test_priority_lookup_uid)
        REFERENCES fieldwork.field_test_priority_lookup (field_test_priority_lookup_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT;

alter table fieldwork.future_porous_pavement        
add CONSTRAINT surface_type_lookup_uid_fkey FOREIGN KEY (surface_type_lookup_uid)
        REFERENCES fieldwork.surface_type_lookup (surface_type_lookup_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT;

-- future srt 

alter table fieldwork.future_srt
add CONSTRAINT con_phase_lookup_uid_fkey FOREIGN KEY (con_phase_lookup_uid)
        REFERENCES fieldwork.con_phase_lookup (con_phase_lookup_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT;

alter table fieldwork.future_srt
add CONSTRAINT field_test_priority_lookup_uid_fkey FOREIGN KEY (field_test_priority_lookup_uid)
        REFERENCES fieldwork.field_test_priority_lookup (field_test_priority_lookup_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT;

alter table fieldwork.future_srt
add CONSTRAINT srt_type_lookup_uid_fkey FOREIGN KEY (srt_type_lookup_uid)
        REFERENCES fieldwork.srt_type_lookup (srt_type_lookup_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT;

-- future_special_investigation
alter table fieldwork.future_special_investigation
add CONSTRAINT con_phase_lookup_uid_fky FOREIGN KEY (con_phase_lookup_uid)
    REFERENCES fieldwork.con_phase_lookup (con_phase_lookup_uid) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE RESTRICT;

alter table fieldwork.future_special_investigation
add CONSTRAINT field_test_priority_lookup_uid_fkey FOREIGN KEY (field_test_priority_lookup_uid)
    REFERENCES fieldwork.field_test_priority_lookup (field_test_priority_lookup_uid) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE RESTRICT;

alter table fieldwork.future_special_investigation
add CONSTRAINT requested_by_lookup_uid_fky FOREIGN KEY (requested_by_lookup_uid)
    REFERENCES fieldwork.requested_by_lookup (requested_by_lookup_uid) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE RESTRICT;

alter table fieldwork.future_special_investigation
add CONSTRAINT special_investigation_lookup_uid_fky FOREIGN KEY (special_investigation_lookup_uid)
    REFERENCES fieldwork.special_investigation_lookup (special_investigation_lookup_uid) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE RESTRICT;

-- METRICS
-- draindown 
alter table metrics.draindown
add CONSTRAINT error_lookup_uid_fkey FOREIGN KEY (error_lookup_uid)
    REFERENCES metrics.error_lookup (error_lookup_uid) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE RESTRICT;

alter table metrics.draindown
add CONSTRAINT observed_simulated_lookup_uid_key FOREIGN KEY (observed_simulated_lookup_uid)
    REFERENCES metrics.observed_simulated_lookup (observed_simulated_lookup_uid) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE RESTRICT;

alter table metrics.draindown
add CONSTRAINT draindown_assessment_lookup_uid_fkey FOREIGN KEY (draindown_assessment_lookup_uid)
    REFERENCES metrics.draindown_assessment_lookup (draindown_assessment_lookup_uid) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE RESTRICT;

alter table metrics.draindown
add CONSTRAINT snapshot_uid_fkey FOREIGN KEY (snapshot_uid)
    REFERENCES metrics.snapshot (snapshot_uid) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE NO ACTION;

-- infiltration 
alter table metrics.infiltration
add CONSTRAINT error_lookup_uid_fkey FOREIGN KEY (error_lookup_uid)
    REFERENCES metrics.error_lookup (error_lookup_uid) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE RESTRICT;

alter table metrics.infiltration
add CONSTRAINT snapshot_uid_fkey FOREIGN KEY (snapshot_uid)
    REFERENCES metrics.snapshot (snapshot_uid) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE NO ACTION;

-- overtopping 
alter table metrics.overtopping
add CONSTRAINT observed_simulated_lookup_uid_key FOREIGN KEY (observed_simulated_lookup_uid)
    REFERENCES metrics.observed_simulated_lookup (observed_simulated_lookup_uid) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE RESTRICT;

alter table metrics.overtopping
add CONSTRAINT snapshot_uid_fkey FOREIGN KEY (snapshot_uid)
    REFERENCES metrics.snapshot (snapshot_uid) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE NO ACTION;

-- percentstorage 
alter table metrics.percentstorage
add CONSTRAINT observed_simulated_lookup_uid_key FOREIGN KEY (observed_simulated_lookup_uid)
    REFERENCES metrics.observed_simulated_lookup (observed_simulated_lookup_uid) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE RESTRICT;

alter table metrics.percentstorage
add CONSTRAINT snapshot_uid_fkey FOREIGN KEY (snapshot_uid)
    REFERENCES metrics.snapshot (snapshot_uid) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE NO ACTION;

-- snapshot_metadata
alter table metrics.snapshot_metadata
add CONSTRAINT snapshot_uid_fkey FOREIGN KEY (snapshot_uid)
    REFERENCES metrics.snapshot (snapshot_uid) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE NO ACTION;

--ADMIN
-- gage_loc
alter table admin.gage_loc 
add constraint gage_uid_fkey FOREIGN KEY (gage_uid)
        REFERENCES admin.gage (gage_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT;

-- radar_loc
alter table admin.radar_loc 
add constraint radar_uid_fkey FOREIGN KEY (radar_uid)
        REFERENCES admin.radar (radar_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT;

-- smp_gage
alter table admin.smp_gage 
add constraint gage_uid_fkey FOREIGN KEY (gage_uid)
        REFERENCES admin.gage (gage_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT;

