--Generating new tables for PG12 
--data schema 

--a.    baro 
CREATE TABLE data.baro
(
    baro_uid serial,
    dtime_est timestamp without time zone NOT NULL,
    baro_psi numeric(6,4) NOT NULL,
    baro_rawfile_uid integer NOT NULL,
    temp_f numeric(8,4),
    CONSTRAINT baro_pkey PRIMARY KEY (baro_uid),
    CONSTRAINT baro_uniqueness UNIQUE (baro_uid, dtime_est)
);

--     CONSTRAINT baro_rawfile_fkey FOREIGN KEY (baro_rawfile_uid)
--         REFERENCES public.baro_rawfile (baro_rawfile_uid) MATCH SIMPLE
--         ON UPDATE CASCADE
--         ON DELETE NO ACTION


--b.	ow_leveldata_raw
CREATE TABLE data.ow_leveldata_raw
(
    ow_leveldata_uid serial,
    dtime_est timestamp without time zone NOT NULL,
    level_ft numeric(8,4) NOT NULL,
    ow_uid integer NOT NULL,
    CONSTRAINT ow_leveldata_raw_pkey PRIMARY KEY (ow_leveldata_uid),
    CONSTRAINT ow_leveldata_uniqueness UNIQUE (ow_uid, dtime_est)
);
--     CONSTRAINT ow_leveldata_ow_validity CHECK (ow_exists(ow_uid) = true) NOT VALID



--c.	gw_depthdata_raw
CREATE TABLE data.gw_depthdata_raw
(
    gw_depthdata_uid serial,
    dtime_est timestamp without time zone NOT NULL,
    depth_ft numeric(8,6) NOT NULL,
    ow_uid integer NOT NULL,
    CONSTRAINT gw_depthdata_pkey PRIMARY KEY (gw_depthdata_uid),
    CONSTRAINT gw_depthdata_uniqueness UNIQUE (ow_uid, dtime_est)
);

--     CONSTRAINT gw_depthdata_ow_validity CHECK (ow_exists(ow_uid) = true) NOT VALID


--d.	rainfall_gage_raw, as gage_rain
CREATE TABLE data.gage_rain
(
    gage_rain_uid serial primary key,
    gage_uid integer NOT NULL,
    dtime_edt timestamp(6) without time zone NOT NULL,
    rainfall_in numeric NOT NULL,
    CONSTRAINT gage_rain_uniqueness UNIQUE (gage_uid, dtime_edt)
);

--     CONSTRAINT rainfall_gage_fkey FOREIGN KEY (gage_uid)
--         REFERENCES public.gage (gage_uid) MATCH SIMPLE
--         ON UPDATE CASCADE
--         ON DELETE RESTRICT


--e.	rainfall_gage_event, as gage_event
CREATE TABLE data.gage_event
(
    gage_event_uid serial primary key,
    gage_uid integer NOT NULL,
    eventdatastart_edt timestamp without time zone NOT NULL,
    eventdataend_edt timestamp without time zone NOT NULL,
    eventduration_hr numeric NOT NULL,
    eventpeakintensity_inhr numeric NOT NULL,
    eventavgintensity_inhr numeric NOT NULL,
    eventdepth_in numeric NOT NULL
); 
    -- CONSTRAINT rainfall_gage_events_fkey FOREIGN KEY (gage_uid)
    --     REFERENCES public.gage (gage_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE NO ACTION


--f.	rainfall_radarcell_raw, as radar_rain
CREATE TABLE data.radar_rain
(
    radar_rain_uid serial primary key,
    radar_uid integer NOT NULL,
    rainfall_in numeric NOT NULL,
    dtime_edt timestamp without time zone NOT NULL,
    CONSTRAINT radar_rain_uniqueness UNIQUE (radar_uid, dtime_edt)
);

--g.	rainfall_radarcell_event, as radar_event
CREATE TABLE data.radar_event
(
    radar_event_uid serial primary key,
    radar_uid integer NOT NULL,
    eventdatastart_edt timestamp without time zone NOT NULL,
    eventdataend_edt timestamp without time zone NOT NULL,
    eventduration_hr numeric NOT NULL,
    eventpeakintensity_inhr numeric NOT NULL,
    eventavgintensity_inhr numeric NOT NULL,
    eventdepth_in numeric NOT NULL
 );
    -- CONSTRAINT rainfall_radarcell_events_fkey FOREIGN KEY (radar_uid)
    --     REFERENCES public.radarcell (radar_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE NO ACTION


-- fieldwork schema

--  a.	capture_efficiency
CREATE TABLE fieldwork.capture_efficiency
(
    capture_efficiency_uid serial,
    system_id text COLLATE pg_catalog."default" NOT NULL,
    component_id text COLLATE pg_catalog."default",
    facility_id uuid,
    test_date timestamp without time zone NOT NULL,
    con_phase_lookup_uid integer,
    low_flow_bypass_observed boolean,
    low_flow_efficiency_pct integer,
    est_high_flow_efficiency_lookup_uid integer,
    high_flow_efficiency_pct integer,
    notes text COLLATE pg_catalog."default",
    user_input_asset_type text COLLATE pg_catalog."default",
    CONSTRAINT capture_efficiency_pkey PRIMARY KEY (capture_efficiency_uid)
);
--     CONSTRAINT con_phase_lookup_uid_fky FOREIGN KEY (con_phase_lookup_uid)
--         REFERENCES fieldwork.con_phase_lookup (con_phase_lookup_uid) MATCH SIMPLE
--         ON UPDATE CASCADE
--         ON DELETE RESTRICT,
--     CONSTRAINT est_high_flow_efficiency_lookup_uid_fkey FOREIGN KEY (est_high_flow_efficiency_lookup_uid)
--         REFERENCES fieldwork.est_high_flow_efficiency_lookup (est_high_flow_efficiency_lookup_uid) MATCH SIMPLE
--         ON UPDATE CASCADE
--         ON DELETE RESTRICT,
--     CONSTRAINT system_id_validity CHECK (system_exists(system_id::character varying) = true) NOT VALID
-- 

--  b.	deployment
CREATE TABLE fieldwork.deployment
(
    deployment_uid serial,
    deployment_dtime_est timestamp without time zone NOT NULL,
    ow_uid integer NOT NULL,
    inventory_sensors_uid integer,
    sensor_purpose integer NOT NULL,
    interval_min integer,
    collection_dtime_est timestamp without time zone,
    long_term_lookup_uid integer,
    research_lookup_uid integer,
    notes text COLLATE pg_catalog."default",
    download_error boolean,
    deployment_dtw_or_depth_ft numeric,
    collection_dtw_or_depth_ft numeric,
    premonitoring_inspection_date timestamp without time zone,
    ready boolean
    CONSTRAINT deployment_pkey PRIMARY KEY (deployment_uid)
);
--     CONSTRAINT inventory_sensors_uid_fkey FOREIGN KEY (inventory_sensors_uid)
--         REFERENCES fieldwork.inventory_sensors (inventory_sensors_uid) MATCH SIMPLE
--         ON UPDATE CASCADE
--         ON DELETE RESTRICT,
--     CONSTRAINT long_term_lookup_uid_fkey FOREIGN KEY (long_term_lookup_uid)
--         REFERENCES fieldwork.long_term_lookup (long_term_lookup_uid) MATCH SIMPLE
--         ON UPDATE CASCADE
--         ON DELETE RESTRICT,
--     CONSTRAINT ow_uid_fkey FOREIGN KEY (ow_uid)
--         REFERENCES fieldwork.ow_all (ow_uid) MATCH SIMPLE
--         ON UPDATE CASCADE
--         ON DELETE RESTRICT,
--     CONSTRAINT check_sensor_deployment CHECK (fieldwork.sensor_isnt_deployed(deployment_uid, inventory_sensors_uid, collection_dtime_est::timestamp with time zone) = true) NOT VALID
-- 

--  c.	inlet_conveyance
CREATE TABLE fieldwork.inlet_conveyance
(
    inlet_conveyance_uid serial,
    system_id text COLLATE pg_catalog."default",
    work_number integer,
    site_name_lookup_uid integer,
    component_id text COLLATE pg_catalog."default",
    facility_id uuid,
    test_date timestamp without time zone NOT NULL,
    con_phase_lookup_uid integer,
    calculated_flow_rate_cfm numeric,
    equilibrated_flow_rate_cfm numeric,
    test_volume_cf numeric,
    max_water_depth_ft numeric,
    surcharge boolean,
    time_to_surcharge_min numeric,
    photos_uploaded boolean,
    summary_report_sent timestamp without time zone,
    notes text COLLATE pg_catalog."default",
    CONSTRAINT inlet_conveyance_pkey PRIMARY KEY (inlet_conveyance_uid)
);
--     CONSTRAINT con_phase_lookup_uid_fky FOREIGN KEY (con_phase_lookup_uid)
--         REFERENCES fieldwork.con_phase_lookup (con_phase_lookup_uid) MATCH SIMPLE
--         ON UPDATE CASCADE
--         ON DELETE RESTRICT,
--     CONSTRAINT system_id_work_number_site_name_lookup_uid_notnull CHECK (NOT (system_id IS NULL AND site_name_lookup_uid IS NULL AND work_number IS NULL))
-- 

--  d.	inventory_sensors
CREATE TABLE fieldwork.inventory_sensors
(
    inventory_sensors_uid serial;
    sensor_serial integer NOT NULL,
    date_purchased timestamp without time zone,
    sensor_status_lookup_uid integer DEFAULT 1,
    sensor_issue_lookup_uid_one integer,
    sensor_issue_lookup_uid_two integer,
    request_data boolean,
    sensor_model_lookup_uid integer,
    CONSTRAINT inventory_sensors_pkey PRIMARY KEY (inventory_sensors_uid)
);
    -- CONSTRAINT sensor_issue_lookup_uid_one_fkey FOREIGN KEY (sensor_issue_lookup_uid_one)
    --     REFERENCES fieldwork.sensor_issue_lookup (sensor_issue_lookup_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE RESTRICT,
    -- CONSTRAINT sensor_issue_lookup_uid_two_fkey FOREIGN KEY (sensor_issue_lookup_uid_two)
    --     REFERENCES fieldwork.sensor_issue_lookup (sensor_issue_lookup_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE RESTRICT,
    -- CONSTRAINT sensor_model_lookup_uid_fkey FOREIGN KEY (sensor_model_lookup_uid)
    --     REFERENCES fieldwork.sensor_model_lookup (sensor_model_lookup_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE RESTRICT,
    -- CONSTRAINT sensor_status_lookup_uid_fkey FOREIGN KEY (sensor_status_lookup_uid)
    --     REFERENCES fieldwork.sensor_status_lookup (sensor_status_lookup_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE RESTRICT


--  e.	ow_all, as ow
CREATE TABLE fieldwork.ow
(
    ow_uid serial;
    smp_id text COLLATE pg_catalog."default",
    ow_suffix text COLLATE pg_catalog."default" NOT NULL,
    facility_id uuid,
    site_name_lookup_uid integer,
    CONSTRAINT ow_pkey PRIMARY KEY (ow_uid),
    CONSTRAINT ow_uniqueness_new UNIQUE (smp_id, ow_suffix, site_name_lookup_uid)
); 
-- 
--     CONSTRAINT facility_id_site_name_lookup_uid_notnull CHECK (NOT (facility_id IS NULL AND site_name_lookup_uid IS NULL)) NOT VALID,
--     CONSTRAINT smp_id_site_name_lookup_uid_notnull CHECK (NOT (smp_id IS NULL AND site_name_lookup_uid IS NULL)) NOT VALID
-- 

--  f.	porous_pavement
CREATE TABLE fieldwork.porous_pavement
(
    porous_pavement_uid serial,
    test_date timestamp without time zone NOT NULL,
    smp_id text COLLATE pg_catalog."default" NOT NULL,
    surface_type_lookup_uid integer,
    con_phase_lookup_uid integer NOT NULL,
    test_location text COLLATE pg_catalog."default",
    data_in_spreadsheet boolean,
    map_in_site_folder boolean,
    ring_diameter_in numeric,
    prewet_time_s numeric,
    prewet_rate_inhr numeric,
    CONSTRAINT porous_pavement_pkey PRIMARY KEY (porous_pavement_uid)
); 

    -- CONSTRAINT con_phase_lookup_uid_fky FOREIGN KEY (con_phase_lookup_uid)
    --     REFERENCES fieldwork.con_phase_lookup (con_phase_lookup_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE RESTRICT,
    -- CONSTRAINT surface_type_lookup_uid_fkey FOREIGN KEY (surface_type_lookup_uid)
    --     REFERENCES fieldwork.surface_type_lookup (surface_type_lookup_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE RESTRICT,
    -- CONSTRAINT smp_id_validity CHECK (smp_exists(smp_id::character varying) = true)

--  g.	porous_pavement_maintenance
CREATE TABLE fieldwork.porous_pavement_maintenance
(
    porous_pavement_maintenance_uid serial,
    smp_id text COLLATE pg_catalog."default" NOT NULL,
    date timestamp without time zone NOT NULL,
    CONSTRAINT porous_pavement_maintenance_pkey PRIMARY KEY (porous_pavement_maintenance_uid)
); 

--     CONSTRAINT smp_id_validity CHECK (smp_exists(smp_id::character varying) = true)
-- 

--  h.	porous_pavement_results
CREATE TABLE fieldwork.porous_pavement_results
(
    porous_pavement_results_uid serial,
    porous_pavement_uid integer,
    weight_lbs numeric,
    time_s numeric,
    rate_inhr numeric,
    CONSTRAINT porous_pavement_results_pkey PRIMARY KEY (porous_pavement_results_uid)
); 

--     CONSTRAINT porous_pavement_uid_fkey FOREIGN KEY (porous_pavement_uid)
--         REFERENCES fieldwork.porous_pavement (porous_pavement_uid) MATCH SIMPLE
--         ON UPDATE CASCADE
--         ON DELETE RESTRICT
-- 

--  i.	special_investigations 
CREATE TABLE fieldwork.special_investigation
(
    special_investigation_uid serial,
    system_id text COLLATE pg_catalog."default",
    work_number integer,
    site_name_lookup_uid integer,
    test_date timestamp without time zone,
    special_investigation_lookup_uid integer NOT NULL,
    requested_by_lookup_uid integer,
    con_phase_lookup_uid integer,
    photos_uploaded boolean,
    sensor_collection_date timestamp without time zone,
    qaqc_complete boolean,
    summary_date timestamp without time zone,
    results_summary text COLLATE pg_catalog."default",
    sensor_deployed boolean,
    summary_needed boolean,
    CONSTRAINT special_investigation_pkey PRIMARY KEY (special_investigation_uid)
); 
--     CONSTRAINT con_phase_lookup_uid_fky FOREIGN KEY (con_phase_lookup_uid)
--         REFERENCES fieldwork.con_phase_lookup (con_phase_lookup_uid) MATCH SIMPLE
--         ON UPDATE CASCADE
--         ON DELETE RESTRICT,
--     CONSTRAINT requested_by_lookup_uid_fky FOREIGN KEY (requested_by_lookup_uid)
--         REFERENCES fieldwork.requested_by_lookup (requested_by_lookup_uid) MATCH SIMPLE
--         ON UPDATE CASCADE
--         ON DELETE RESTRICT,
--     CONSTRAINT special_investigation_lookup_uid_fky FOREIGN KEY (special_investigation_lookup_uid)
--         REFERENCES fieldwork.special_investigation_lookup (special_investigation_lookup_uid) MATCH SIMPLE
--         ON UPDATE CASCADE
--         ON DELETE RESTRICT,
--     CONSTRAINT system_id_work_number_site_name_lookup_uid_notnull CHECK (NOT (system_id IS NULL AND site_name_lookup_uid IS NULL AND work_number IS NULL))
-- )


--  j.	srt
CREATE TABLE fieldwork.srt
(
    srt_uid serial,
    system_id text COLLATE pg_catalog."default" NOT NULL,
    test_date timestamp without time zone NOT NULL,
    con_phase_lookup_uid integer NOT NULL,
    srt_type_lookup_uid integer NOT NULL,
    srt_volume_ft3 numeric,
    dcia_ft2 numeric,
    srt_stormsize_in numeric,
    srt_summary text COLLATE pg_catalog."default",
    CONSTRAINT srt_pkey PRIMARY KEY (srt_uid)
); 
    -- CONSTRAINT con_phase_lookup_uid_fkey FOREIGN KEY (con_phase_lookup_uid)
    --     REFERENCES fieldwork.con_phase_lookup (con_phase_lookup_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE RESTRICT,
    -- CONSTRAINT srt_type_lookup_uid_fkey FOREIGN KEY (srt_type_lookup_uid)
    --     REFERENCES fieldwork.srt_type_lookup (srt_type_lookup_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE RESTRICT,
    -- CONSTRAINT system_id_validity CHECK (system_exists(system_id::character varying) = true) NOT VALID



--  k.	well_measuremnts
CREATE TABLE fieldwork.well_measurements
(
    well_measurements_uid serial,
    ow_uid integer NOT NULL,
    well_depth_ft numeric(8,4) NOT NULL,
    start_dtime_est timestamp without time zone,
    end_dtime_est timestamp without time zone,
    sensor_one_inch_off_bottom boolean,
    cap_to_hook_ft numeric(8,4),
    hook_to_sensor_ft numeric(8,4),
    cap_to_weir_ft numeric(8,4),
    cap_to_orifice_ft numeric(8,4),
    weir boolean,
    CONSTRAINT well_measurements_pkey PRIMARY KEY (well_measurements_uid)
);
    -- CONSTRAINT ow_leveldata_ow_validity CHECK (ow_exists(ow_uid) = true) NOT VALID


--  l.	future_capture_efficiency
CREATE TABLE fieldwork.future_capture_efficiency
(
    future_capture_efficiency_uid serial,
    system_id text COLLATE pg_catalog."default" NOT NULL,
    component_id text COLLATE pg_catalog."default",
    facility_id uuid,
    con_phase_lookup_uid integer,
    notes text COLLATE pg_catalog."default",
    field_test_priority_lookup_uid integer,
    user_input_asset_type text COLLATE pg_catalog."default",
    CONSTRAINT future_capture_efficiency_pkey PRIMARY KEY (future_capture_efficiency_uid)
); 
    -- CONSTRAINT con_phase_lookup_uid_fky FOREIGN KEY (con_phase_lookup_uid)
    --     REFERENCES fieldwork.con_phase_lookup (con_phase_lookup_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE RESTRICT,
    -- CONSTRAINT field_test_priority_lookup_uid_fkey FOREIGN KEY (field_test_priority_lookup_uid)
    --     REFERENCES fieldwork.field_test_priority_lookup (field_test_priority_lookup_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE RESTRICT,
    -- CONSTRAINT system_id_validity CHECK (system_exists(system_id::character varying) = true) NOT VALID


--  m.	future_deployment
CREATE TABLE fieldwork.future_deployment
(
    future_deployment_uid serial,
    ow_uid integer NOT NULL,
    inventory_sensors_uid integer,
    sensor_purpose integer,
    interval_min integer,
    long_term_lookup_uid integer,
    research_lookup_uid integer,
    notes text COLLATE pg_catalog."default",
    field_test_priority_lookup_uid integer,
    premonitoring_inspection timestamp without time zone,
    ready boolean,
    CONSTRAINT future_deployment_pkey PRIMARY KEY (future_deployment_uid)
); 
    -- CONSTRAINT field_test_priority_lookup_uid_fkey FOREIGN KEY (field_test_priority_lookup_uid)
    --     REFERENCES fieldwork.field_test_priority_lookup (field_test_priority_lookup_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE RESTRICT,
    -- CONSTRAINT inventory_sensors_uid_fkey FOREIGN KEY (inventory_sensors_uid)
    --     REFERENCES fieldwork.inventory_sensors (inventory_sensors_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE RESTRICT,
    -- CONSTRAINT long_term_lookup_uid_fkey FOREIGN KEY (long_term_lookup_uid)
    --     REFERENCES fieldwork.long_term_lookup (long_term_lookup_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE RESTRICT,
    -- CONSTRAINT ow_uid_fkey FOREIGN KEY (ow_uid)
    --     REFERENCES fieldwork.ow_all (ow_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE RESTRICT

--  n.	future_inlet_conveyance
CREATE TABLE fieldwork.future_inlet_conveyance
(
    future_inlet_conveyance_uid serial,
    system_id text COLLATE pg_catalog."default",
    work_number integer,
    site_name_lookup_uid integer,
    component_id text COLLATE pg_catalog."default",
    facility_id uuid,
    con_phase_lookup_uid integer,
    calculated_flow_rate_cfm numeric,
    field_test_priority_lookup_uid integer,
    notes text COLLATE pg_catalog."default",
    CONSTRAINT future_inlet_conveyance_pkey PRIMARY KEY (future_inlet_conveyance_uid)
); 
    -- CONSTRAINT con_phase_lookup_uid_fky FOREIGN KEY (con_phase_lookup_uid)
    --     REFERENCES fieldwork.con_phase_lookup (con_phase_lookup_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE RESTRICT,
    -- CONSTRAINT field_test_priority_lookup_uid_fkey FOREIGN KEY (field_test_priority_lookup_uid)
    --     REFERENCES fieldwork.field_test_priority_lookup (field_test_priority_lookup_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE RESTRICT,
    -- CONSTRAINT system_id_site_name_lookup_uid_notnull CHECK (NOT (system_id IS NULL AND site_name_lookup_uid IS NULL AND work_number IS NULL)) NOT VALID

--  o.	future_porous_pavement
CREATE TABLE fieldwork.future_porous_pavement
(
    future_porous_pavement_uid serial,
    smp_id text COLLATE pg_catalog."default" NOT NULL,
    surface_type_lookup_uid integer,
    con_phase_lookup_uid integer,
    test_location text COLLATE pg_catalog."default",
    field_test_priority_lookup_uid integer,
    CONSTRAINT future_porous_pavement_pkey PRIMARY KEY (future_porous_pavement_uid)
); 
    -- CONSTRAINT con_phase_lookup_uid_fky FOREIGN KEY (con_phase_lookup_uid)
    --     REFERENCES fieldwork.con_phase_lookup (con_phase_lookup_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE RESTRICT,
    -- CONSTRAINT field_test_priority_lookup_uid_fkey FOREIGN KEY (field_test_priority_lookup_uid)
    --     REFERENCES fieldwork.field_test_priority_lookup (field_test_priority_lookup_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE RESTRICT,
    -- CONSTRAINT surface_type_lookup_uid_fkey FOREIGN KEY (surface_type_lookup_uid)
    --     REFERENCES fieldwork.surface_type_lookup (surface_type_lookup_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE RESTRICT,
    -- CONSTRAINT smp_id_validity CHECK (smp_exists(smp_id::character varying) = true) NOT VALID

--  p.	future_srt
CREATE TABLE fieldwork.future_srt
(
    future_srt_uid serial,
    system_id text COLLATE pg_catalog."default" NOT NULL,
    con_phase_lookup_uid integer,
    srt_type_lookup_uid integer,
    dcia_ft2 numeric,
    notes text COLLATE pg_catalog."default",
    field_test_priority_lookup_uid integer,
    CONSTRAINT future_srt_pkey PRIMARY KEY (future_srt_uid)
); 
    -- CONSTRAINT con_phase_lookup_uid_fkey FOREIGN KEY (con_phase_lookup_uid)
    --     REFERENCES fieldwork.con_phase_lookup (con_phase_lookup_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE RESTRICT,
    -- CONSTRAINT field_test_priority_lookup_uid_fkey FOREIGN KEY (field_test_priority_lookup_uid)
    --     REFERENCES fieldwork.field_test_priority_lookup (field_test_priority_lookup_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE RESTRICT,
    -- CONSTRAINT srt_type_lookup_uid_fkey FOREIGN KEY (srt_type_lookup_uid)
    --     REFERENCES fieldwork.srt_type_lookup (srt_type_lookup_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE RESTRICT,
    -- CONSTRAINT system_id_validity CHECK (system_exists(system_id::character varying) = true) NOT VALID
)

--  q.	future_special_investigations
CREATE TABLE fieldwork.future_special_investigation
(
    future_special_investigation_uid serial,
    system_id text COLLATE pg_catalog."default",
    work_number integer,
    site_name_lookup_uid integer,
    special_investigation_lookup_uid integer NOT NULL,
    requested_by_lookup_uid integer,
    con_phase_lookup_uid integer,
    field_test_priority_lookup_uid integer,
    notes text COLLATE pg_catalog."default",
    CONSTRAINT future_special_investigation_pkey PRIMARY KEY (future_special_investigation_uid)
); 
    -- CONSTRAINT con_phase_lookup_uid_fky FOREIGN KEY (con_phase_lookup_uid)
    --     REFERENCES fieldwork.con_phase_lookup (con_phase_lookup_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE RESTRICT,
    -- CONSTRAINT field_test_priority_lookup_uid_fkey FOREIGN KEY (field_test_priority_lookup_uid)
    --     REFERENCES fieldwork.field_test_priority_lookup (field_test_priority_lookup_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE RESTRICT,
    -- CONSTRAINT requested_by_lookup_uid_fky FOREIGN KEY (requested_by_lookup_uid)
    --     REFERENCES fieldwork.requested_by_lookup (requested_by_lookup_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE RESTRICT,
    -- CONSTRAINT special_investigation_lookup_uid_fky FOREIGN KEY (special_investigation_lookup_uid)
    --     REFERENCES fieldwork.special_investigation_lookup (special_investigation_lookup_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE RESTRICT,
    -- CONSTRAINT system_id_work_number_site_name_lookup_uid_notnull CHECK (NOT (system_id IS NULL AND site_name_lookup_uid IS NULL AND work_number IS NULL))


--  r.	custom_project_names
CREATE TABLE fieldwork.custom_project_names
(
    custom_project_name_uid serial,
    project_id integer,
    project_name text COLLATE pg_catalog."default",
    CONSTRAINT custom_project_names_pkey PRIMARY KEY (custom_project_name_uid)
);

-- 3.	Metrics Schema

--  a.  	performance_draindown_radarcell, as draindown
CREATE TABLE metrics.draindown
(
    draindown_uid serial primary key,
    draindown_hr numeric(8,4),
    observed_simulated_lookup_uid integer NOT NULL,
    ow_uid integer NOT NULL,
    radar_event_uid integer NOT NULL,
    snapshot_uid integer NOT NULL,
    performance_draindown_assessment_lookup_uid integer NOT NULL,
    error_lookup_uid integer
); 

    -- CONSTRAINT error_lookup_uid_fkey FOREIGN KEY (error_lookup_uid)
    --     REFERENCES public.performance_error_lookup (error_lookup_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE RESTRICT,
    -- CONSTRAINT observed_simulated_lookup_uid_key FOREIGN KEY (observed_simulated_lookup_uid)
    --     REFERENCES public.observed_simulated_lookup (observed_simulated_lookup_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE RESTRICT,
    -- CONSTRAINT performance_draindown_assessment_lookup_uid_fkey FOREIGN KEY (performance_draindown_assessment_lookup_uid)
    --     REFERENCES public.performance_draindown_assessment_lookup (performance_draindown_assessment_lookup_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE RESTRICT,
    -- CONSTRAINT snapshot_uid_fkey FOREIGN KEY (snapshot_uid)
    --     REFERENCES public.snapshot (snapshot_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE RESTRICT,
    -- CONSTRAINT ow_validity CHECK (ow_exists(ow_uid) = true)


--  b.  	performance_infiltration_radarcell, as infiltration
CREATE TABLE metrics.infiltration
(
    infiltration_uid serial primary key,
    infiltration_rate_inhr numeric(8,4),
    baseline_ft numeric(8,4),
    ow_uid integer NOT NULL,
    radar_event_uid integer NOT NULL,
    snapshot_uid integer NOT NULL,
    error_lookup_uid integer,
    observed_simulated_lookup_uid integer
); 

    -- CONSTRAINT error_lookup_uid_fkey FOREIGN KEY (error_lookup_uid)
    --     REFERENCES public.performance_error_lookup (error_lookup_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE RESTRICT,
    -- CONSTRAINT snapshot_uid_fkey FOREIGN KEY (snapshot_uid)
    --     REFERENCES public.snapshot (snapshot_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE RESTRICT,
    -- CONSTRAINT ow_validity CHECK (ow_exists(ow_uid) = true)

--  c.  	performance_overtopping_radarcell, as overtopping
CREATE TABLE metrics.overtopping
(
    overtopping_uid serial primary key,
    overtopping boolean NOT NULL,
    observed_simulated_lookup_uid integer NOT NULL,
    ow_uid integer NOT NULL,
    radar_event_uid integer NOT NULL,
    snapshot_uid integer NOT NULL
); 
    -- CONSTRAINT observed_simulated_lookup FOREIGN KEY (observed_simulated_lookup_uid)
    --     REFERENCES public.observed_simulated_lookup (observed_simulated_lookup_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE RESTRICT,
    -- CONSTRAINT snapshot_uid_fkey FOREIGN KEY (snapshot_uid)
    --     REFERENCES public.snapshot (snapshot_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE RESTRICT,
    -- CONSTRAINT ow_validity CHECK (ow_exists(ow_uid) = true)

--  d.  	performance_percentstorage_radarcell, as percentstorage
CREATE TABLE metrics.percentstorage
(
    percentstorage_uid serial primary key,
    percentstorage numeric(7,4) NOT NULL,
    relative boolean NOT NULL,
    observed_simulated_lookup_uid integer NOT NULL,
    ow_uid integer NOT NULL,
    radar_event_uid integer NOT NULL,
    snapshot_uid integer NOT NULL
); 
    -- CONSTRAINT observed_simulated_lookup FOREIGN KEY (observed_simulated_lookup_uid)
    --     REFERENCES public.observed_simulated_lookup (observed_simulated_lookup_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE RESTRICT,
    -- CONSTRAINT snapshot_uid_fkey FOREIGN KEY (snapshot_uid)
    --     REFERENCES public.snapshot (snapshot_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE RESTRICT,
    -- CONSTRAINT ow_validity CHECK (ow_exists(ow_uid) = true)

--  e.  	snapshot
CREATE TABLE metrics.snapshot
(
    snapshot_uid serial,
    ow_uid integer NOT NULL,
    dcia_ft2 numeric,
    storage_footprint_ft2 numeric,
    orifice_diam_in numeric,
    infil_footprint_ft2 numeric,
    assumption_orificeheight_ft numeric,
    storage_depth_ft numeric,
    sumpdepth_ft numeric,
    lined boolean,
    surface boolean,
    storage_volume_ft3 numeric,
    infil_dsg_rate_inhr numeric,
    old_stays_valid boolean DEFAULT false,
    CONSTRAINT snapshot_pkey PRIMARY KEY (snapshot_uid)
);
    -- CONSTRAINT snapshot_ow_validity CHECK (ow_exists(ow_uid) = true) NOT VALID

--  f.  	snapshot_metadata
CREATE TABLE metrics.snapshot_metadata
(
    snapshot_metadata_uid serial,
    snapshot_uid integer NOT NULL,
    ow_uid integer NOT NULL,
    date_start_est timestamp without time zone NOT NULL,
    date_end_est timestamp without time zone NOT NULL,
    md5hash text COLLATE pg_catalog."default" NOT NULL,
    is_valid boolean DEFAULT true,
    old_stays_valid boolean DEFAULT false,
    CONSTRAINT snapshot_metadata_pkey PRIMARY KEY (snapshot_metadata_uid)
); 
    -- CONSTRAINT snapshot_uid_fkey FOREIGN KEY (snapshot_uid)
    --     REFERENCES public.snapshot (snapshot_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE NO ACTION,
    -- CONSTRAINT snapshot_metadata_ow_validity CHECK (ow_exists(ow_uid) = true) NOT VALID
)

--4.	Admin Schema

--a.	accessdb
CREATE TABLE admin.accessdb
(
    accessdb_uid serial,
    ow_uid integer NOT NULL,
    filepath character varying COLLATE pg_catalog."default" NOT NULL,
    datatable character varying COLLATE pg_catalog."default",
    sumptable character varying COLLATE pg_catalog."default",
    CONSTRAINT accessdb_testing_pkey PRIMARY KEY (accessdb_uid),
    CONSTRAINT accessdb_datatable_uniqueness UNIQUE (accessdb_uid, datatable),
    CONSTRAINT accessdb_ow_uniqueness UNIQUE (ow_uid),
    CONSTRAINT accessdb_sumptable_uniqueness UNIQUE (accessdb_uid, sumptable)
); 
    -- CONSTRAINT ow_uid_fkey FOREIGN KEY (ow_uid)
    --     REFERENCES fieldwork.ow_all (ow_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE RESTRICT


--b.	baro_rawfile
CREATE TABLE admin.baro_rawfile
(
    baro_rawfile_uid serial,
    smp_id character varying COLLATE pg_catalog."default" NOT NULL,
    filepath character varying COLLATE pg_catalog."default" NOT NULL,
    md5hash character varying COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT baro_rawfile_pkey PRIMARY KEY (baro_rawfile_uid),
    CONSTRAINT baro_rawfile_filepath_uniqueness UNIQUE (filepath),
    CONSTRAINT baro_rawfile_md5hash_uniqueness UNIQUE (md5hash)
);
--     CONSTRAINT smp_id_validity CHECK (smp_exists(smp_id) = true) NOT VALID
-- )

--c.	baro_rawfolder
CREATE TABLE admin.baro_rawfolder
(
    baro_rawfolder_uid serial,
    smp_id character varying COLLATE pg_catalog."default" NOT NULL,
    folderpath character varying COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT baro_rawfolder_pkey PRIMARY KEY (baro_rawfolder_uid),
    CONSTRAINT baro_rawfolder_folderpath_uniqueness UNIQUE (folderpath)
); 

    -- CONSTRAINT smp_id_validity CHECK (smp_exists(smp_id) = true) NOT VALID


--d.	gage
CREATE TABLE admin.gage
(
    gage_uid serial,
    gagename character varying COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT gage_pkey PRIMARY KEY (gage_uid),
    CONSTRAINT gage_name_uniqueness UNIQUE (gagename)
);

--e.	gage_loc
CREATE TABLE admin.gage_loc
(
    gage_loc_uid serial,
    gage_uid integer NOT NULL,
    lon_wgs84 numeric(10,6) NOT NULL,
    lat_wgs84 numeric(10,6) NOT NULL,
    CONSTRAINT gage_loc_pkey PRIMARY KEY (gage_loc_uid),
    CONSTRAINT gage_loc_uniqueness UNIQUE (lon_wgs84, lat_wgs84)
);
    -- CONSTRAINT gage_loc_fkey FOREIGN KEY (gage_uid)
    --     REFERENCES public.gage (gage_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE RESTRICT

--f.	radarcell, as radar
CREATE TABLE admin.radar
(
	--this was previously an integer not a serial, so i left it like that. not sure if it is best
    radar_uid integer NOT NULL,
    CONSTRAINT radar_pkey PRIMARY KEY (radar_uid)
);

--g.	radarcell_loc, as radar_loc
CREATE TABLE admin.radar_loc
(
    radar_loc_uid serial primary key,
    radar_uid integer NOT NULL,
    lon_wgs84 numeric(10,6) NOT NULL,
    lat_wgs84 numeric(10,6) NOT NULL,
    CONSTRAINT radar_loc_uniqueness UNIQUE (lon_wgs84, lat_wgs84)
); 
    -- CONSTRAINT radarcell_loc_fkey FOREIGN KEY (radarcell_uid)
    --     REFERENCES public.radarcell (radarcell_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE NO ACTION

--h.	radarcell_rawfile, as radar_rawfile
CREATE TABLE admin.radar_rawfile
(
    radar_rawfile_uid serial primary key,
    filepath text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT radar_rawfile_uniqueness UNIQUE (filepath)
);

--i.	smp_gage
CREATE TABLE admin.smp_gage
(
    smp_gage_uid serial,
    smp_id character varying COLLATE pg_catalog."default" NOT NULL,
    gage_uid integer NOT NULL,
    CONSTRAINT smp_gage_pkey PRIMARY KEY (smp_gage_uid),
    CONSTRAINT smp_gage_uniqueness UNIQUE (smp_id)
); 
    -- CONSTRAINT gage_uid_fkey FOREIGN KEY (gage_uid)
    --     REFERENCES public.gage (gage_uid) MATCH SIMPLE
    --     ON UPDATE CASCADE
    --     ON DELETE NO ACTION,
    -- CONSTRAINT smp_id_validity CHECK (smp_exists(smp_id) = true) NOT VALID


--j.	smp_loc
CREATE TABLE public.smp_loc
(
    smp_loc_uid serial,
    smp_id character varying COLLATE pg_catalog."default" NOT NULL,
    lon_wgs84 double precision NOT NULL,
    lat_wgs84 double precision NOT NULL,
    CONSTRAINT smp_loc_pkey PRIMARY KEY (smp_loc_uid),
    CONSTRAINT smp_loc_uniqueness UNIQUE (smp_id, lon_wgs84, lat_wgs84)
); 

    -- CONSTRAINT smp_id_validity CHECK (smp_exists(smp_id) = true) NOT VALID


--k.	smp_radarcell, as smp_radar

CREATE TABLE public.smp_radar
(
    smp_radar_uid serial primary key,
    radar_uid integer NOT NULL,
    smp_id text COLLATE pg_catalog."default" NOT NULL
);

-- CONSTRAINT smp_id_validity CHECK (smp_exists(smp_id::character varying) = true) NOT VALID


--l.	monitoring_deny_list
CREATE TABLE fieldwork.monitoring_deny_list
(
    monitoring_deny_list_uid serial,
    smp_id character varying COLLATE pg_catalog."default",
    reason text COLLATE pg_catalog."default",
    CONSTRAINT monitoring_deny_list_pkey PRIMARY KEY (monitoring_deny_list_uid)
);
