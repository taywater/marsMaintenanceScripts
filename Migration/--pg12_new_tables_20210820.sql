--pg12_new_tables_20210820

-- fieldwork.con_phase_lookup

CREATE TABLE fieldwork.con_phase_lookup
(
    con_phase_lookup_uid integer NOT NULL,
    phase text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT con_phase_lookup_pkey PRIMARY KEY (con_phase_lookup_uid)
);

-- fieldwork.est_high_flow_efficiency_lookup
CREATE TABLE fieldwork.est_high_flow_efficiency_lookup
(
    est_high_flow_efficiency_lookup_uid integer NOT NULL,
    est_high_flow_efficiency text COLLATE pg_catalog."default",
    CONSTRAINT est_high_flow_lookup_efficiency_pkey PRIMARY KEY (est_high_flow_efficiency_lookup_uid)
);


-- fieldwork.long_term_lookup
CREATE TABLE fieldwork.long_term_lookup
(
    long_term_lookup_uid integer NOT NULL,
    type text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT long_term_lookup_pkey PRIMARY KEY (long_term_lookup_uid)
);

-- fieldwork.research_lookup

CREATE TABLE fieldwork.research_lookup
(
    research_lookup_uid integer NOT NULL,
    type text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT research_lookup_pkey PRIMARY KEY (research_lookup_uid)
);

-- fieldwork.sensor_issue_lookup

CREATE TABLE fieldwork.sensor_issue_lookup
(
    sensor_issue_lookup_uid integer NOT NULL primary key,
    sensor_issue text COLLATE pg_catalog."default"
);

-- fieldwork.sensor_model_lookup
CREATE TABLE fieldwork.sensor_model_lookup
(
    sensor_model_lookup_uid integer NOT NULL primary key,
    sensor_model text COLLATE pg_catalog."default" NOT NULL,
    status_description text COLLATE pg_catalog."default"
);


-- fieldwork.sensor_status_lookup
CREATE TABLE fieldwork.sensor_status_lookup
(
    sensor_status_lookup_uid integer NOT NULL,
    sensor_status text COLLATE pg_catalog."default",
    status_description text COLLATE pg_catalog."default",
    CONSTRAINT sensor_status_lookup_pkey PRIMARY KEY (sensor_status_lookup_uid)
);


-- fieldwork.surface_type_lookup
CREATE TABLE fieldwork.surface_type_lookup
(
    surface_type_lookup_uid integer NOT NULL,
    surface_type text COLLATE pg_catalog."default",
    CONSTRAINT surface_type_lookup_pkey PRIMARY KEY (surface_type_lookup_uid)
);

-- fieldwork.requested_by_lookup
CREATE TABLE fieldwork.requested_by_lookup
(
    requested_by_lookup_uid integer NOT NULL,
    requested_by text COLLATE pg_catalog."default",
    CONSTRAINT requested_by_lookup_pkey PRIMARY KEY (requested_by_lookup_uid)
);

-- fieldwork.srt_type_lookup
CREATE TABLE fieldwork.srt_type_lookup
(
    srt_type_lookup_uid integer NOT NULL,
    type text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT srt_type_lookup_pkey PRIMARY KEY (srt_type_lookup_uid)
);

-- fieldwork.field_test_priority_lookup
CREATE TABLE fieldwork.field_test_priority_lookup
(
    field_test_priority_lookup_uid integer NOT NULL,
    field_test_priority text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT field_test_priority_lookup_pkey PRIMARY KEY (field_test_priority_lookup_uid)
);

-- fieldwork.special_investigation_lookup
CREATE TABLE fieldwork.special_investigation_lookup
(
    special_investigation_lookup_uid integer NOT NULL,
    special_investigation_type text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT special_investigation_lookup_pkey PRIMARY KEY (special_investigation_lookup_uid)
);

-- metrics.observed_simulated_lookup
CREATE TABLE metrics.observed_simulated_lookup
(
    observed_simulated_lookup_uid integer NOT NULL,
    type text COLLATE pg_catalog."default",
    CONSTRAINT observed_simulated_lookup_pkey PRIMARY KEY (observed_simulated_lookup_uid)
);


-- metrics.draindown_assessment_lookup
CREATE TABLE metrics.draindown_assessment_lookup
(
    draindown_assessment_lookup_uid integer NOT NULL primary key,
    draindown_assessment_description text COLLATE pg_catalog."default"
);


-- metrics.error_lookup
CREATE TABLE metrics.error_lookup
(
    error_lookup_uid integer NOT NULL,
    error_description text COLLATE pg_catalog."default",
    CONSTRAINT performance_error_lookup_pkey PRIMARY KEY (error_lookup_uid)
);


