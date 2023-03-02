--FIELDWORK APP

--TABLES to check for 
-- ow_prefixes
CREATE TABLE fieldwork.ow_prefixes
(
    ow_prefixes_uid serial,
    ow_prefix text COLLATE pg_catalog."default",
    ow_name text COLLATE pg_catalog."default" NOT NULL,
    componentless boolean,
    CONSTRAINT ow_prefixes_pkey PRIMARY KEY (ow_prefixes_uid)
)


-- site_name_lookup

CREATE TABLE fieldwork.site_name_lookup
(
    site_name_lookup_uid serial,
    site_name text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT site_name_lookup_pkey PRIMARY KEY (site_name_lookup_uid)
)

--sensor_purpose_lookup FKA deployment_lookup

CREATE TABLE fieldwork.sensor_purpose_lookup
(
    sensor_purpose_lookup_uid integer NOT NULL,
    type text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT deployment_lookup_pkey PRIMARY KEY (sensor_purpose_lookup_uid)
)

--gwsi_conveyance_subtype_lookup
CREATE TABLE fieldwork.gswi_conveyance_subtype_lookup
(
    code integer,
    description text COLLATE pg_catalog."default"
)

--fieldwork:

-- project names 

CREATE VIEW fieldwork.project_names
AS
 SELECT pr.project_id,
    pr.worknumber,
    smp.smp_id,
    admin.smp_to_system(smp.smp_id::character varying) AS system_id,
    COALESCE(cpn.project_name, pr.proj_projectname) AS project_name,
    cp.project_title AS cipit_title
   FROM external.projectbdv pr
     LEFT JOIN external.smpbdv smp ON pr.project_id = smp.project_id
     LEFT JOIN external.cipit_project cp ON cp.work_number::text = pr.worknumber
     LEFT JOIN fieldwork.custom_project_names cpn ON pr.project_id = cpn.project_id
UNION
 SELECT pl."ProjectID" AS project_id,
    NULL::text AS worknumber,
    pl."SMPID"::text AS smp_id,
    pl."SMPID"::text AS system_id,
    COALESCE(cpn.project_name, cr."Projectname") AS project_name,
    NULL::text AS cipit_title
   FROM external.planreview_view_smp_designation pl
     LEFT JOIN external.planreview_view_smpsummary_crosstab_asbuiltall cr ON pl."SMPID" = cr."SMPID"
     LEFT JOIN fieldwork.custom_project_names cpn ON pl."ProjectID" = cpn.project_id;

-- ow_ownership
CREATE OR REPLACE VIEW fieldwork.ow_ownership
 AS
 SELECT o.ow_uid,
    fieldwork.public_private(pl."SMPID"::text) AS public
   FROM fieldwork.ow o
     LEFT JOIN external.planreview_view_smp_designation pl ON pl."SMPID"::text = o.smp_id;


-- deployment_full

CREATE OR REPLACE VIEW fieldwork.deployment_full
 AS
 SELECT fd.deployment_uid,
    fd.deployment_dtime_est,
    fow.smp_id,
    fow.ow_suffix,
    pn.project_name AS greenit_name,
    fd.ow_uid,
    fd.sensor_purpose,
    de.type,
    fd.long_term_lookup_uid,
    lt.type AS term,
    fd.research_lookup_uid,
    rs.type AS research,
    fd.interval_min,
    own.public,
    pr."Designation" AS designation,
    pr."OOWProgramType" AS oow_program_type,
    pr."SMIP" AS smip,
    pr."GARP" AS garp,
    fd.inventory_sensors_uid,
    inv.sensor_serial,
    fd.collection_dtime_est,
    fd.notes,
    fd.download_error,
    lag(fd.download_error, 1) OVER (PARTITION BY fd.ow_uid, inv.sensor_serial ORDER BY fd.deployment_dtime_est) AS previous_download_error,
    fow.site_name_lookup_uid,
    snl.site_name,
    COALESCE(pn.project_name, snl.site_name) AS project_name,
    sfc.component_id,
    fd.deployment_dtw_or_depth_ft,
    fd.collection_dtw_or_depth_ft,
    fd.premonitoring_inspection_date,
    fd.ready
   FROM fieldwork.deployment fd
     LEFT JOIN fieldwork.ow fow ON fd.ow_uid = fow.ow_uid
     LEFT JOIN fieldwork.inventory_sensors inv ON fd.inventory_sensors_uid = inv.inventory_sensors_uid
     LEFT JOIN fieldwork.sensor_purpose_lookup de ON fd.sensor_purpose = de.sensor_purpose_lookup_uid
     LEFT JOIN fieldwork.long_term_lookup lt ON lt.long_term_lookup_uid = fd.long_term_lookup_uid
     LEFT JOIN fieldwork.research_lookup rs ON rs.research_lookup_uid = fd.research_lookup_uid
     LEFT JOIN fieldwork.ow_ownership own ON fd.ow_uid = own.ow_uid
     LEFT JOIN external.planreview_view_smp_designation pr ON fow.smp_id = pr."SMPID"::text
     LEFT JOIN fieldwork.project_names pn ON fow.smp_id = pn.smp_id
     LEFT JOIN fieldwork.site_name_lookup snl ON fow.site_name_lookup_uid = snl.site_name_lookup_uid
     LEFT JOIN external.assets sfc ON fow.facility_id = sfc.facility_id;

-- deployment_full_cwl

CREATE OR REPLACE VIEW fieldwork.deployment_full_cwl
 AS
 SELECT deployment_full.deployment_uid,
    deployment_full.deployment_dtime_est,
    deployment_full.smp_id,
    deployment_full.ow_suffix,
    deployment_full.greenit_name,
    deployment_full.ow_uid,
    deployment_full.sensor_purpose,
    deployment_full.type,
    deployment_full.long_term_lookup_uid,
    deployment_full.term,
    deployment_full.research_lookup_uid,
    deployment_full.research,
    deployment_full.interval_min,
    deployment_full.public,
    deployment_full.designation,
    deployment_full.oow_program_type,
    deployment_full.smip,
    deployment_full.garp,
    deployment_full.inventory_sensors_uid,
    deployment_full.sensor_serial,
    deployment_full.collection_dtime_est,
    deployment_full.notes,
    deployment_full.download_error,
    deployment_full.previous_download_error,
    deployment_full.site_name_lookup_uid,
    deployment_full.site_name,
    deployment_full.project_name,
    deployment_full.component_id,
    deployment_full.deployment_dtw_or_depth_ft,
    deployment_full.collection_dtw_or_depth_ft,
    deployment_full.premonitoring_inspection_date,
    deployment_full.ready
   FROM fieldwork.deployment_full
  WHERE ((deployment_full.term = ANY (ARRAY['Short'::text, 'Long'::text, 'NA'::text])) OR deployment_full.term IS NULL) AND deployment_full.type = 'LEVEL'::text;

-- porous_pavement_full
CREATE OR REPLACE VIEW fieldwork.porous_pavement_full
 AS
 SELECT pp.porous_pavement_uid,
    pp.test_date,
    pp.smp_id,
    stl.surface_type,
    con.phase,
    pp.test_location,
    pp.data_in_spreadsheet,
    pp.map_in_site_folder,
    pn.project_name,
    fieldwork.public_private(pl."SMPID"::text) AS public
   FROM fieldwork.porous_pavement pp
     LEFT JOIN fieldwork.con_phase_lookup con ON pp.con_phase_lookup_uid = con.con_phase_lookup_uid
     LEFT JOIN fieldwork.project_names pn ON pp.smp_id = pn.smp_id
     LEFT JOIN fieldwork.surface_type_lookup stl ON pp.surface_type_lookup_uid = stl.surface_type_lookup_uid
     LEFT JOIN external.planreview_view_smp_designation pl ON pl."SMPID"::text = pp.smp_id;

-- porous_pavement_wide
CREATE OR REPLACE VIEW fieldwork.porous_pavement_wide
 AS
 WITH test_one AS (
         SELECT DISTINCT ON (porous_pavement_results.porous_pavement_uid) porous_pavement_results.porous_pavement_results_uid,
            porous_pavement_results.porous_pavement_uid,
            porous_pavement_results.weight_lbs,
            porous_pavement_results.time_s,
            porous_pavement_results.rate_inhr
           FROM fieldwork.porous_pavement_results
          ORDER BY porous_pavement_results.porous_pavement_uid, porous_pavement_results.porous_pavement_results_uid
        ), test_two AS (
         SELECT porous_pavement_results.porous_pavement_results_uid,
            porous_pavement_results.porous_pavement_uid,
            porous_pavement_results.weight_lbs,
            porous_pavement_results.time_s,
            porous_pavement_results.rate_inhr
           FROM fieldwork.porous_pavement_results
          WHERE NOT (porous_pavement_results.porous_pavement_results_uid IN ( SELECT test_one.porous_pavement_results_uid
                   FROM test_one))
          ORDER BY porous_pavement_results.porous_pavement_uid, porous_pavement_results.porous_pavement_results_uid
        )
 SELECT pp.porous_pavement_uid,
    pp.test_date,
    pp.smp_id,
    stl.surface_type,
    con.phase,
    pp.test_location,
    pp.data_in_spreadsheet,
    pp.map_in_site_folder,
    pn.project_name,
    fieldwork.public_private(pl."SMPID"::text) AS public,
    pp.ring_diameter_in,
    pp.prewet_time_s,
    pp.prewet_rate_inhr,
    tn.porous_pavement_results_uid AS test_one_porous_pavement_results_uid,
    tn.weight_lbs AS test_one_weight_lbs,
    tn.time_s AS test_one_time_s,
    tn.rate_inhr AS test_one_rate_inhr,
    tt.porous_pavement_results_uid AS test_two_porous_pavement_results_uid,
    tt.weight_lbs AS test_two_weight_lbs,
    tt.time_s AS test_two_time_s,
    tt.rate_inhr AS test_two_rate_inhr,
    COALESCE(pp.prewet_rate_inhr, (tn.rate_inhr + tt.rate_inhr) / 2::numeric, tn.rate_inhr) AS average_rate_inhr
   FROM fieldwork.porous_pavement pp
     LEFT JOIN fieldwork.con_phase_lookup con ON pp.con_phase_lookup_uid = con.con_phase_lookup_uid
     LEFT JOIN fieldwork.project_names pn ON pp.smp_id = pn.smp_id
     LEFT JOIN fieldwork.surface_type_lookup stl ON pp.surface_type_lookup_uid = stl.surface_type_lookup_uid
     LEFT JOIN external.planreview_view_smp_designation pl ON pl."SMPID"::text = pp.smp_id
     LEFT JOIN test_one tn ON pp.porous_pavement_uid = tn.porous_pavement_uid
     LEFT JOIN test_two tt ON pp.porous_pavement_uid = tt.porous_pavement_uid;


-- porous_pavement_smp_averages
CREATE OR REPLACE VIEW fieldwork.porous_pavement_smp_averages
 AS
 SELECT ppar.smp_id,
    pn.project_name,
    ppar.test_date,
    avg(ppar.average_rate_inhr) AS avg_rate_inhr
   FROM fieldwork.porous_pavement_wide ppar
     LEFT JOIN fieldwork.project_names pn ON ppar.smp_id = pn.smp_id
  GROUP BY ppar.smp_id, ppar.test_date, pn.project_name
  ORDER BY ppar.smp_id, ppar.test_date;


-- future_porous_pavement_full
CREATE OR REPLACE VIEW fieldwork.future_porous_pavement_full
 AS
 SELECT pp.future_porous_pavement_uid,
    pp.smp_id,
    pn.project_name,
    stl.surface_type,
    con.phase,
    pp.test_location,
    pp.field_test_priority_lookup_uid,
    ft.field_test_priority
   FROM fieldwork.future_porous_pavement pp
     LEFT JOIN fieldwork.con_phase_lookup con ON pp.con_phase_lookup_uid = con.con_phase_lookup_uid
     LEFT JOIN fieldwork.surface_type_lookup stl ON pp.surface_type_lookup_uid = stl.surface_type_lookup_uid
     LEFT JOIN fieldwork.project_names pn ON pp.smp_id = pn.smp_id
     LEFT JOIN fieldwork.field_test_priority_lookup ft ON pp.field_test_priority_lookup_uid = ft.field_test_priority_lookup_uid;

-- ow_plus_measurements
CREATE OR REPLACE VIEW fieldwork.ow_plus_measurements
 AS
 SELECT ow.ow_uid,
    w.well_measurements_uid,
    ow.smp_id,
    ow.ow_suffix,
    ow.facility_id,
    ow.site_name_lookup_uid,
    snl.site_name,
    w.well_depth_ft,
    w.start_dtime_est,
    w.end_dtime_est,
    w.sensor_one_inch_off_bottom,
    w.weir,
    w.cap_to_hook_ft,
    w.hook_to_sensor_ft,
    fieldwork.installation_height_ft(w.sensor_one_inch_off_bottom, w.well_depth_ft, w.cap_to_hook_ft, w.hook_to_sensor_ft) AS installation_height_ft,
    w.cap_to_hook_ft + w.hook_to_sensor_ft AS deployment_depth_ft,
    w.cap_to_weir_ft,
    w.cap_to_orifice_ft,
    fieldwork.weir_to_sensor_ft(w.sensor_one_inch_off_bottom, w.weir, w.well_depth_ft, w.cap_to_hook_ft, w.hook_to_sensor_ft, w.cap_to_weir_ft) AS weir_to_sensor_ft,
    fieldwork.weir_to_orifice_ft(w.weir, w.cap_to_weir_ft, w.cap_to_orifice_ft) AS weir_to_orifice_ft,
    fieldwork.orifice_to_sensor_ft(w.sensor_one_inch_off_bottom, w.weir, w.well_depth_ft, w.cap_to_hook_ft, w.hook_to_sensor_ft, w.cap_to_orifice_ft) AS orifice_to_sensor_ft
   FROM fieldwork.ow ow
     LEFT JOIN fieldwork.well_measurements w ON ow.ow_uid = w.ow_uid
     LEFT JOIN fieldwork.site_name_lookup snl ON snl.site_name_lookup_uid = ow.site_name_lookup_uid;

-- inventory_sensors_full
CREATE OR REPLACE VIEW fieldwork.inventory_sensors_full
 AS
 SELECT inv.sensor_serial,
    sml.sensor_model,
    inv.date_purchased,
    ow.smp_id,
    snl.site_name,
    ow.ow_suffix,
    ssl.sensor_status,
    inv.sensor_issue_lookup_uid_one,
    silo.sensor_issue AS issue_one,
    inv.sensor_issue_lookup_uid_two,
    silt.sensor_issue AS issue_two,
    inv.request_data,
    inv.sensor_model_lookup_uid,
    inv.inventory_sensors_uid
   FROM fieldwork.inventory_sensors inv
     LEFT JOIN fieldwork.deployment d ON d.inventory_sensors_uid = inv.inventory_sensors_uid AND d.collection_dtime_est IS NULL
     LEFT JOIN fieldwork.ow ow ON ow.ow_uid = d.ow_uid
     LEFT JOIN fieldwork.sensor_status_lookup ssl ON ssl.sensor_status_lookup_uid = inv.sensor_status_lookup_uid
     LEFT JOIN fieldwork.site_name_lookup snl ON snl.site_name_lookup_uid = ow.site_name_lookup_uid
     LEFT JOIN fieldwork.sensor_issue_lookup silo ON inv.sensor_issue_lookup_uid_one = silo.sensor_issue_lookup_uid
     LEFT JOIN fieldwork.sensor_issue_lookup silt ON inv.sensor_issue_lookup_uid_two = silt.sensor_issue_lookup_uid
     LEFT JOIN fieldwork.sensor_model_lookup sml ON inv.sensor_model_lookup_uid = sml.sensor_model_lookup_uid;

-- active_deployments
CREATE OR REPLACE VIEW fieldwork.active_deployments
 AS
 SELECT deployment_full.deployment_uid,
    deployment_full.deployment_dtime_est,
    deployment_full.smp_id,
    deployment_full.ow_suffix,
    deployment_full.project_name,
    deployment_full.ow_uid,
    deployment_full.sensor_purpose,
    deployment_full.type,
    deployment_full.long_term_lookup_uid,
    deployment_full.term,
    deployment_full.research_lookup_uid,
    deployment_full.research,
    deployment_full.interval_min,
    deployment_full.public,
    deployment_full.designation,
    deployment_full.oow_program_type,
    deployment_full.smip,
    deployment_full.garp,
    deployment_full.deployment_dtime_est + deployment_full.interval_min::double precision * '12 days'::interval AS date_80percent,
    deployment_full.deployment_dtime_est + deployment_full.interval_min::double precision * '15 days'::interval AS date_100percent,
    deployment_full.inventory_sensors_uid,
    deployment_full.sensor_serial,
    date_part('month'::text, deployment_full.deployment_dtime_est) AS collection_month,
    date_part('year'::text, deployment_full.deployment_dtime_est) AS collection_year,
    deployment_full.notes,
    deployment_full.download_error,
    deployment_full.previous_download_error,
    deployment_full.site_name_lookup_uid,
    deployment_full.site_name,
    deployment_full.component_id,
    deployment_full.deployment_dtw_or_depth_ft,
    deployment_full.premonitoring_inspection_date,
    deployment_full.ready
   FROM fieldwork.deployment_full
  WHERE deployment_full.collection_dtime_est IS NULL AND (deployment_full.smp_id IS NOT NULL OR deployment_full.site_name_lookup_uid IS NOT NULL)
  ORDER BY deployment_full.smp_id, deployment_full.ow_suffix, deployment_full.sensor_purpose, deployment_full.deployment_dtime_est;

-- previous_deployments
CREATE OR REPLACE VIEW fieldwork.previous_deployments
 AS
 SELECT fd.deployment_uid,
    fd.deployment_dtime_est,
    fow.smp_id,
    fow.ow_suffix,
    fd.ow_uid,
    fd.sensor_purpose,
    de.type,
    lt.type AS term,
    rs.type AS research,
    fd.interval_min,
    fd.inventory_sensors_uid,
    inv.sensor_serial,
    fd.collection_dtime_est,
    fd.notes,
    fd.download_error,
    fow.site_name_lookup_uid,
    snl.site_name,
    fd.deployment_dtw_or_depth_ft,
    fd.collection_dtw_or_depth_ft,
    fd.premonitoring_inspection_date,
    fd.ready
   FROM fieldwork.deployment fd
     LEFT JOIN fieldwork.ow fow ON fd.ow_uid = fow.ow_uid
     LEFT JOIN fieldwork.inventory_sensors inv ON fd.inventory_sensors_uid = inv.inventory_sensors_uid
     LEFT JOIN fieldwork.sensor_purpose_lookup de ON fd.sensor_purpose = de.sensor_purpose_lookup_uid
     LEFT JOIN fieldwork.long_term_lookup lt ON lt.long_term_lookup_uid = fd.long_term_lookup_uid
     LEFT JOIN fieldwork.research_lookup rs ON rs.research_lookup_uid = fd.research_lookup_uid
     LEFT JOIN fieldwork.site_name_lookup snl ON fow.site_name_lookup_uid = snl.site_name_lookup_uid
  WHERE fd.collection_dtime_est IS NOT NULL AND (fow.smp_id IS NOT NULL OR fow.site_name_lookup_uid IS NOT NULL);


-- future_deployments_full
CREATE OR REPLACE VIEW fieldwork.future_deployments_full
 AS
 SELECT fd.future_deployment_uid,
    fow.smp_id,
    fow.ow_suffix,
    pn.project_name AS greenit_name,
    fd.ow_uid,
    fd.sensor_purpose,
    de.type,
    fd.long_term_lookup_uid,
    lt.type AS term,
    fd.research_lookup_uid,
    rs.type AS research,
    fd.interval_min,
    own.public,
    pr."Designation" AS designation,
    pr."OOWProgramType" AS oow_program_type,
    pr."SMIP" AS smip,
    pr."GARP" AS garp,
    fd.inventory_sensors_uid,
    inv.sensor_serial,
    fd.field_test_priority_lookup_uid,
    ft.field_test_priority,
    fd.notes,
    fow.site_name_lookup_uid,
    snl.site_name,
    COALESCE(pn.project_name, snl.site_name) AS project_name,
    fd.premonitoring_inspection,
    fd.ready
   FROM fieldwork.future_deployment fd
     LEFT JOIN fieldwork.ow fow ON fd.ow_uid = fow.ow_uid
     LEFT JOIN fieldwork.inventory_sensors inv ON fd.inventory_sensors_uid = inv.inventory_sensors_uid
     LEFT JOIN fieldwork.sensor_purpose_lookup de ON fd.sensor_purpose = de.sensor_purpose_lookup_uid
     LEFT JOIN fieldwork.long_term_lookup lt ON lt.long_term_lookup_uid = fd.long_term_lookup_uid
     LEFT JOIN fieldwork.research_lookup rs ON rs.research_lookup_uid = fd.research_lookup_uid
     LEFT JOIN fieldwork.ow_ownership own ON fd.ow_uid = own.ow_uid
     LEFT JOIN fieldwork.field_test_priority_lookup ft ON fd.field_test_priority_lookup_uid = ft.field_test_priority_lookup_uid
     LEFT JOIN external.planreview_view_smp_designation pr ON fow.smp_id = pr."SMPID"::text
     LEFT JOIN fieldwork.project_names pn ON fow.smp_id = pn.smp_id
     LEFT JOIN fieldwork.site_name_lookup snl ON fow.site_name_lookup_uid = snl.site_name_lookup_uid;

-- capture_efficiency_full
CREATE OR REPLACE VIEW fieldwork.capture_efficiency_full
 AS
 SELECT DISTINCT cet.capture_efficiency_uid,
    cet.system_id,
    cet.test_date,
    cet.component_id,
    cet.facility_id,
    con.phase,
    cet.low_flow_bypass_observed,
    cet.low_flow_efficiency_pct,
    hf.est_high_flow_efficiency,
    cet.high_flow_efficiency_pct,
    COALESCE(cet.user_input_asset_type, sfc.asset_type) AS asset_type,
    cet.notes,
    pn.project_name,
    fieldwork.public_private(pl."SMPID"::text) AS public
   FROM fieldwork.capture_efficiency cet
     LEFT JOIN fieldwork.con_phase_lookup con ON cet.con_phase_lookup_uid = con.con_phase_lookup_uid
     LEFT JOIN fieldwork.est_high_flow_efficiency_lookup hf ON cet.est_high_flow_efficiency_lookup_uid = hf.est_high_flow_efficiency_lookup_uid
     LEFT JOIN external.assets_cet sfc ON cet.facility_id = sfc.facility_id
     LEFT JOIN fieldwork.project_names pn ON cet.system_id = pn.system_id::text
     LEFT JOIN external.planreview_view_smp_designation pl ON pl."SMPID"::text = cet.system_id;

-- capture_efficiency_full_unique_inlets
CREATE OR REPLACE VIEW fieldwork.capture_efficiency_full_unique_inlets
 AS
 SELECT ct1.capture_efficiency_uid,
    ct1.system_id,
    ct1.test_date,
    ct1.component_id,
    ct1.facility_id,
    ct1.phase,
    ct1.low_flow_bypass_observed,
    ct1.low_flow_efficiency_pct,
    ct1.est_high_flow_efficiency,
    ct1.high_flow_efficiency_pct,
    ct1.asset_type,
    ct1.notes,
    ct1.project_name,
    ct1.public
   FROM fieldwork.capture_efficiency_full ct1
     LEFT JOIN fieldwork.capture_efficiency_full ct2 ON ct1.component_id = ct2.component_id AND ct1.system_id = ct2.system_id AND (ct1.test_date < ct2.test_date OR ct1.test_date = ct2.test_date AND ct1.capture_efficiency_uid > ct2.capture_efficiency_uid)
  WHERE ct2.component_id IS NULL;

-- future_capture_efficiency_full
CREATE OR REPLACE VIEW fieldwork.future_capture_efficiency_full
 AS
 SELECT DISTINCT ON (cet.future_capture_efficiency_uid) cet.future_capture_efficiency_uid,
    cet.system_id,
    pn.project_name,
    cet.component_id,
    cet.facility_id,
    con.phase,
    COALESCE(cet.user_input_asset_type, sfc.asset_type) AS asset_type,
    cet.field_test_priority_lookup_uid,
    ft.field_test_priority,
    cet.notes
   FROM fieldwork.future_capture_efficiency cet
     LEFT JOIN fieldwork.con_phase_lookup con ON cet.con_phase_lookup_uid = con.con_phase_lookup_uid
     LEFT JOIN external.assets_cet sfc ON cet.facility_id = sfc.facility_id
     LEFT JOIN fieldwork.project_names pn ON cet.system_id = pn.system_id::text
     LEFT JOIN fieldwork.field_test_priority_lookup ft ON cet.field_test_priority_lookup_uid = ft.field_test_priority_lookup_uid;

-- deployment_full_cwl_with_baro
CREATE OR REPLACE VIEW fieldwork.deployment_full_cwl_with_baro
 AS
 SELECT deployment_full.deployment_uid,
    deployment_full.deployment_dtime_est,
    deployment_full.smp_id,
    deployment_full.ow_suffix,
    deployment_full.greenit_name,
    deployment_full.ow_uid,
    deployment_full.sensor_purpose,
    deployment_full.type,
    deployment_full.long_term_lookup_uid,
    deployment_full.term,
    deployment_full.research_lookup_uid,
    deployment_full.research,
    deployment_full.interval_min,
    deployment_full.public,
    deployment_full.designation,
    deployment_full.oow_program_type,
    deployment_full.smip,
    deployment_full.garp,
    deployment_full.inventory_sensors_uid,
    deployment_full.sensor_serial,
    deployment_full.collection_dtime_est,
    deployment_full.notes,
    deployment_full.download_error,
    deployment_full.previous_download_error,
    deployment_full.site_name_lookup_uid,
    deployment_full.site_name,
    deployment_full.project_name,
    deployment_full.component_id,
    deployment_full.deployment_dtw_or_depth_ft,
    deployment_full.collection_dtw_or_depth_ft
   FROM fieldwork.deployment_full
  WHERE ((deployment_full.term = ANY (ARRAY['Short'::text, 'Long'::text, 'NA'::text])) OR deployment_full.term IS NULL) AND (deployment_full.type = ANY (ARRAY['LEVEL'::text, 'BARO'::text]));



-- active_cwl_sites
CREATE OR REPLACE VIEW fieldwork.active_cwl_sites
 AS
 SELECT DISTINCT dfc.smp_id,
    dfc.ow_suffix,
    dfc.site_name,
    dfc.component_id,
    dfc.project_name,
    dfc.public,
    dfc.type,
    min(df.deployment_dtime_est) AS first_deployment_date,
    "left"(dfc.ow_suffix, 2) AS location_type
   FROM fieldwork.deployment_full_cwl_with_baro dfc
     LEFT JOIN fieldwork.deployment_full df ON dfc.ow_uid = df.ow_uid
  WHERE dfc.collection_dtime_est IS NULL
  GROUP BY dfc.smp_id, dfc.ow_suffix, dfc.site_name, dfc.component_id, dfc.project_name, dfc.public, dfc.type;

-- previous_cwl_sites
CREATE OR REPLACE VIEW fieldwork.previous_cwl_sites
 AS
 SELECT DISTINCT dfc.smp_id,
    dfc.ow_suffix,
    dfc.site_name,
    dfc.component_id,
    dfc.project_name,
    dfc.public,
    dfc.type,
    "left"(dfc.ow_suffix, 2) AS location_type,
    min(dfc.deployment_dtime_est) AS first_deployment_date,
    max(dfc.collection_dtime_est) AS last_collection_date
   FROM fieldwork.deployment_full_cwl_with_baro dfc
     LEFT JOIN fieldwork.active_cwl_sites ac ON dfc.smp_id = ac.smp_id
  WHERE ac.smp_id IS NULL
  GROUP BY dfc.smp_id, dfc.ow_suffix, dfc.site_name, dfc.component_id, dfc.project_name, dfc.public, dfc.type;

-- special_investigation_full
CREATE OR REPLACE VIEW fieldwork.special_investigation_full
 AS
 SELECT DISTINCT si.special_investigation_uid,
    si.system_id,
    si.work_number,
    si.site_name_lookup_uid,
    snl.site_name,
    pn.project_name AS greenit_name,
    COALESCE(snl.site_name, pn.project_name, ((pr.cipit_title || ' (WN '::text) || si.work_number::text) || ')'::text) AS project_name,
    si.test_date,
    si.special_investigation_lookup_uid,
    sil.special_investigation_type,
    si.requested_by_lookup_uid,
    rbl.requested_by,
    si.con_phase_lookup_uid,
    con.phase,
    si.sensor_deployed,
    si.sensor_collection_date,
    si.photos_uploaded,
    si.qaqc_complete,
    si.summary_date,
    si.summary_date - si.test_date AS turnaround_days,
    si.results_summary,
    si.summary_needed
   FROM fieldwork.special_investigation si
     LEFT JOIN fieldwork.site_name_lookup snl ON si.site_name_lookup_uid = snl.site_name_lookup_uid
     LEFT JOIN fieldwork.requested_by_lookup rbl ON si.requested_by_lookup_uid = rbl.requested_by_lookup_uid
     LEFT JOIN fieldwork.special_investigation_lookup sil ON si.special_investigation_lookup_uid = sil.special_investigation_lookup_uid
     LEFT JOIN fieldwork.con_phase_lookup con ON si.con_phase_lookup_uid = con.con_phase_lookup_uid
     LEFT JOIN fieldwork.project_names pn ON si.system_id = pn.system_id::text
     LEFT JOIN fieldwork.project_names pr ON si.work_number::text = pr.worknumber;

-- future_special_investigation_full
CREATE OR REPLACE VIEW fieldwork.future_special_investigation_full
 AS
 SELECT DISTINCT si.future_special_investigation_uid,
    si.system_id,
    si.work_number,
    si.site_name_lookup_uid,
    snl.site_name,
    pn.project_name AS greenit_name,
    COALESCE(snl.site_name, pn.project_name, ((pr.cipit_title || ' (WN '::text) || si.work_number::text) || ')'::text) AS project_name,
    si.special_investigation_lookup_uid,
    sil.special_investigation_type,
    si.requested_by_lookup_uid,
    rbl.requested_by,
    si.con_phase_lookup_uid,
    con.phase,
    si.field_test_priority_lookup_uid,
    ft.field_test_priority,
    si.notes
   FROM fieldwork.future_special_investigation si
     LEFT JOIN fieldwork.site_name_lookup snl ON si.site_name_lookup_uid = snl.site_name_lookup_uid
     LEFT JOIN fieldwork.requested_by_lookup rbl ON si.requested_by_lookup_uid = rbl.requested_by_lookup_uid
     LEFT JOIN fieldwork.special_investigation_lookup sil ON si.special_investigation_lookup_uid = sil.special_investigation_lookup_uid
     LEFT JOIN fieldwork.con_phase_lookup con ON si.con_phase_lookup_uid = con.con_phase_lookup_uid
     LEFT JOIN fieldwork.field_test_priority_lookup ft ON si.field_test_priority_lookup_uid = ft.field_test_priority_lookup_uid
     LEFT JOIN fieldwork.project_names pn ON si.system_id = pn.system_id::text
     LEFT JOIN fieldwork.project_names pr ON si.work_number::text = pr.worknumber;

-- srt_full
CREATE OR REPLACE VIEW fieldwork.srt_full
 AS
 SELECT DISTINCT srt.srt_uid,
    srt.system_id,
    srt.test_date,
    con.phase,
    typ.type,
    srt.srt_volume_ft3,
    srt.dcia_ft2,
    srt.srt_stormsize_in,
    srt.flow_data_recorded,
    srt.water_level_recorded,
    srt.photos_uploaded,
    srt.sensor_collection_date,
    srt.qaqc_complete,
    srt.srt_summary_date,
    srt.srt_summary_date - srt.test_date AS turnaround_days,
    srt.srt_summary,
    pn.project_name,
    srt.sensor_deployed,
    fieldwork.public_private(pl."SMPID"::text) AS public
   FROM fieldwork.srt
     LEFT JOIN fieldwork.srt_type_lookup typ ON srt.srt_type_lookup_uid = typ.srt_type_lookup_uid
     LEFT JOIN fieldwork.con_phase_lookup con ON srt.con_phase_lookup_uid = con.con_phase_lookup_uid
     LEFT JOIN fieldwork.project_names pn ON srt.system_id = pn.system_id::text
     LEFT JOIN external.planreview_view_smp_designation pl ON pl."SMPID"::text = srt.system_id;

-- future_srt_full
CREATE OR REPLACE VIEW fieldwork.future_srt_full
 AS
 SELECT DISTINCT ON (f.future_srt_uid) f.future_srt_uid,
    f.system_id,
    pn.project_name,
    con.phase,
    typ.type,
    f.dcia_ft2,
    gr.sys_storagevolume_ft3,
    gr.sys_rawstormsizemanaged_in,
    gr.sys_storagevolume_ft3 / gr.sys_rawstormsizemanaged_in AS one_inch_storm_volume_cf,
    f.field_test_priority_lookup_uid,
    ft.field_test_priority,
    f.notes
   FROM fieldwork.future_srt f
     LEFT JOIN fieldwork.srt_type_lookup typ ON f.srt_type_lookup_uid = typ.srt_type_lookup_uid
     LEFT JOIN fieldwork.con_phase_lookup con ON f.con_phase_lookup_uid = con.con_phase_lookup_uid
     LEFT JOIN fieldwork.project_names pn ON f.system_id = pn.system_id::text
     LEFT JOIN fieldwork.field_test_priority_lookup ft ON f.field_test_priority_lookup_uid = ft.field_test_priority_lookup_uid
     LEFT JOIN external.systembdv gr ON f.system_id = gr.system_id;

-- inlet_conveyance_full
CREATE OR REPLACE VIEW fieldwork.inlet_conveyance_full
 AS
 SELECT ic.inlet_conveyance_uid,
    ic.system_id,
    ic.work_number,
    ic.site_name_lookup_uid,
    snl.site_name,
    COALESCE(pn.project_name) AS greenit_name,
    COALESCE(snl.site_name, pn.project_name, ((pr.cipit_title || ' (WN '::text) || ic.work_number::text) || ')'::text) AS project_name,
    ic.component_id,
    ic.facility_id,
    ic.test_date,
    ic.con_phase_lookup_uid,
    con.phase,
    ic.calculated_flow_rate_cfm,
    ic.equilibrated_flow_rate_cfm,
    ic.test_volume_cf,
    ic.max_water_depth_ft,
    ic.surcharge,
    ic.time_to_surcharge_min,
    ic.photos_uploaded,
    ic.summary_report_sent,
    ic.summary_report_sent - ic.test_date AS turnaround_days,
    ic.notes
   FROM fieldwork.inlet_conveyance ic
     LEFT JOIN fieldwork.site_name_lookup snl ON ic.site_name_lookup_uid = snl.site_name_lookup_uid
     LEFT JOIN fieldwork.con_phase_lookup con ON ic.con_phase_lookup_uid = con.con_phase_lookup_uid
     LEFT JOIN fieldwork.project_names pn ON ic.system_id = pn.system_id::text
     LEFT JOIN fieldwork.project_names pr ON ic.work_number::text = pr.worknumber;

-- future_inlet_conveyance_full
CREATE OR REPLACE VIEW fieldwork.future_inlet_conveyance_full
 AS
 SELECT ic.future_inlet_conveyance_uid,
    ic.system_id,
    ic.work_number,
    ic.site_name_lookup_uid,
    snl.site_name,
    pn.project_name AS greenit_name,
    COALESCE(snl.site_name, pn.project_name, ((pr.cipit_title || ' (WN '::text) || ic.work_number::text) || ')'::text) AS project_name,
    ic.component_id,
    ic.facility_id,
    ic.con_phase_lookup_uid,
    con.phase,
    ic.calculated_flow_rate_cfm,
    ic.field_test_priority_lookup_uid,
    ft.field_test_priority,
    ic.notes
   FROM fieldwork.future_inlet_conveyance ic
     LEFT JOIN fieldwork.site_name_lookup snl ON ic.site_name_lookup_uid = snl.site_name_lookup_uid
     LEFT JOIN fieldwork.con_phase_lookup con ON ic.con_phase_lookup_uid = con.con_phase_lookup_uid
     LEFT JOIN fieldwork.project_names pn ON ic.system_id = pn.system_id::text
     LEFT JOIN fieldwork.project_names pr ON ic.work_number::text = pr.worknumber
     LEFT JOIN fieldwork.field_test_priority_lookup ft ON ic.field_test_priority_lookup_uid = ft.field_test_priority_lookup_uid;


-- unmonitored_active_smps
CREATE OR REPLACE VIEW fieldwork.unmonitored_active_smps
 AS
 WITH inactive_inlets AS (
         SELECT gswiinlet.lifecycle_status,
            gswiinlet.facility_id,
            admin.component_to_smp(gswiinlet.component_id::character varying) AS smp_id,
            admin.smp_to_system(admin.component_to_smp(gswiinlet.component_id::character varying)) AS system_id,
            gswiinlet.component_id
           FROM external.gswiinlet
          WHERE (gswiinlet.lifecycle_status <> 'ACT'::text OR gswiinlet.plug_status <> 'ONLINE'::text) AND gswiinlet.component_id IS NOT NULL
        UNION
         SELECT c.lifecycle_status,
            c.facility_id,
            admin.component_to_smp(btrim(c.component_id, ' '::text)::character varying) AS smp_id,
            admin.smp_to_system(admin.component_to_smp(btrim(c.component_id, ' '::text)::character varying)) AS system_id,
            c.component_id
           FROM external.gswiconveyance c
             LEFT JOIN fieldwork.gswi_conveyance_subtype_lookup lo ON c.subtype = lo.code
          WHERE c.component_id IS NOT NULL AND c.lifecycle_status <> 'ACT'::text
        UNION
         SELECT s.lifecycle_status,
            s.facility_id,
            admin.component_to_smp(btrim(s.component_id, ' '::text)::character varying) AS smp_id,
            admin.smp_to_system(admin.component_to_smp(btrim(s.component_id, ' '::text)::character varying)) AS system_id,
            s.component_id
           FROM external.gswistructure s
          WHERE s.component_id IS NOT NULL AND s.lifecycle_status <> 'ACT'::text
        ), greenit_built_info AS (
         SELECT smpbdv.smp_id,
            smpbdv.system_id,
            smpbdv.smp_notbuiltretired,
            smpbdv.smp_smptype,
            smpbdv.capit_status
           FROM external.smpbdv
          WHERE smpbdv.smp_notbuiltretired IS NULL AND smpbdv.smp_smptype <> 'Depaving'::text
        ), cwl_smp AS (
         SELECT DISTINCT deployment_full_cwl.smp_id
           FROM fieldwork.deployment_full_cwl
        ), cwl_system AS (
         SELECT DISTINCT admin.smp_to_system(deployment_full_cwl.smp_id::character varying) AS system_id
           FROM fieldwork.deployment_full_cwl
        ), srt_systems AS (
         SELECT DISTINCT srt_full.system_id
           FROM fieldwork.srt_full
        )
 SELECT DISTINCT gbi.smp_id,
    gbi.smp_smptype AS smp_type,
    gbi.capit_status,
        CASE
            WHEN sys.system_id IS NULL THEN false
            WHEN sys.system_id IS NOT NULL THEN true
            ELSE NULL::boolean
        END AS other_cwl_at_this_system
   FROM greenit_built_info gbi
     LEFT JOIN cwl_system sys ON sys.system_id::text = gbi.system_id
  WHERE (gbi.capit_status = ANY (ARRAY['Construction-Substantially Complete'::text, 'Closed'::text])) AND NOT (EXISTS ( SELECT cs.smp_id
           FROM cwl_smp cs
          WHERE cs.smp_id = gbi.smp_id)) AND NOT (EXISTS ( SELECT ss.system_id
           FROM srt_systems ss
          WHERE ss.system_id = gbi.system_id)) AND NOT (EXISTS ( SELECT ii.smp_id
           FROM inactive_inlets ii
          WHERE ii.system_id::text = gbi.system_id)) AND NOT (EXISTS ( SELECT deny.smp_id
           FROM admin.monitoring_deny_list deny
          WHERE deny.smp_id::text = gbi.smp_id)) AND NOT (EXISTS ( SELECT cet.system_id
           FROM fieldwork.capture_efficiency cet
          WHERE cet.system_id = gbi.system_id AND gbi.smp_smptype = 'Stormwater Tree'::text)) AND NOT (EXISTS ( SELECT ppt.smp_id
           FROM fieldwork.porous_pavement ppt
          WHERE ppt.smp_id = gbi.smp_id AND ppt.test_date > (now() - '2 years'::interval)))
  ORDER BY gbi.smp_id;

--public 
--barodata_smp 
CREATE OR REPLACE VIEW data.barodata_smp
 AS
 SELECT b.dtime_est,
    r.smp_id,
    b.baro_psi,
    b.temp_f
   FROM data.baro b
     LEFT JOIN baro_rawfile r ON b.baro_rawfile_uid = r.baro_rawfile_uid;

-- barodata_neighbors
CREATE OR REPLACE VIEW data.barodata_neighbors
 AS
 SELECT barodata_smp.dtime_est,
    count(*) AS neighbors
   FROM data.barodata_smp
  GROUP BY barodata_smp.dtime_est;


------NEW TABLES 2021/09/07
--ow sumpdepth default 

CREATE TABLE fieldwork.ow_sumpdepth_default
(
    ow_sumpdepth_default_uid integer NOT NULL,
    ow_prefix text COLLATE pg_catalog."default",
    sumpdepth_ft numeric,
    CONSTRAINT ow_sumpdepth_default_pkey PRIMARY KEY (ow_sumpdepth_default_uid)
);


CREATE TABLE  fieldwork.ow_sumpdepth_intermediate
(
    ow_sumpdepth_intermediate_uid integer NOT NULL DEFAULT nextval('ow_sumpdepth_uid_seq'::regclass),
    ow_uid integer NOT NULL,
    sumpdepth_ft numeric(8,4) NOT NULL DEFAULT 1,
    CONSTRAINT ow_sumpdepth_intermediate_pkey PRIMARY KEY (ow_sumpdepth_intermediate_uid),
    CONSTRAINT ow_sumpdepth_uniqueness UNIQUE (ow_uid),
    CONSTRAINT ow_uid_fkey FOREIGN KEY (ow_uid)
    REFERENCES fieldwork.ow (ow_uid) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE NO ACTION
);




-------NEW VIEWS 2021/09/07

--public -> data 
--rainfall_gage 
CREATE OR REPLACE VIEW data.gage_rainfall
 AS
 SELECT rg.gage_rain_uid AS gage_rain_uid,
    rg.dtime_edt,
    rg.gage_uid,
    rg.rainfall_in,
    rge.gage_event_uid
   FROM data.gage_rain rg
     LEFT JOIN data.gage_event rge ON rg.gage_uid = rge.gage_uid AND rg.dtime_edt >= rge.eventdatastart_edt AND rg.dtime_edt <= rge.eventdataend_edt;

--data.radar_rainfall
CREATE OR REPLACE VIEW data.radar_rainfall
 AS
 SELECT rc.radar_rain_uid,
    rc.dtime_edt,
    rc.radar_uid,
    rc.rainfall_in,
    rce.radar_event_uid
   FROM data.radar_rain rc
     LEFT JOIN data.radar_event rce ON rc.radar_uid = rce.radar_uid AND rc.dtime_edt >= rce.eventdatastart_edt AND rc.dtime_edt <= rce.eventdataend_edt;

-- fieldwork.ow_sumpdepth_lined
CREATE OR REPLACE VIEW fieldwork.ow_sumpdepth_lined
 AS
 SELECT o.ow_uid,
    0 AS sumpdepth_ft
   FROM external.greenit_unified gu
     LEFT JOIN fieldwork.ow o ON gu.ow_uid = o.ow_uid
  WHERE gu.lined IS TRUE AND o.ow_uid IS NOT NULL;

-- fieldwork.ow_sumpdepth
CREATE OR REPLACE VIEW fieldwork.ow_sumpdepth
 AS
 SELECT ow.ow_uid,
    round(COALESCE(round(osi.sumpdepth_ft, 4), osl.sumpdepth_ft::numeric, osd.sumpdepth_ft), 4) AS sumpdepth_ft
   FROM fieldwork.ow ow
     LEFT JOIN fieldwork.ow_sumpdepth_lined osl ON ow.ow_uid = osl.ow_uid
     LEFT JOIN fieldwork.ow_sumpdepth_intermediate osi ON ow.ow_uid = osi.ow_uid
     LEFT JOIN fieldwork.ow_sumpdepth_default osd ON "substring"(ow.ow_suffix, 1, 2) = osd.ow_prefix;

CREATE OR REPLACE VIEW data.ow_leveldata_sumpcorrected
 AS
 SELECT od.ow_leveldata_uid,
    od.dtime_est,
    GREATEST(round(od.level_ft - osd.sumpdepth_ft, 4), 0::numeric) AS level_ft,
    ow.smp_id,
    ow.ow_suffix,
    ow.ow_uid
   FROM data.ow_leveldata_raw od
     LEFT JOIN fieldwork.ow ow ON od.ow_uid = ow.ow_uid
     LEFT JOIN fieldwork.ow_sumpdepth osd ON od.ow_uid = osd.ow_uid;