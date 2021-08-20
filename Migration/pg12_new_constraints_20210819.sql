--pg12_new_constraints_20210819

#20210819
#added and then dropped these constraints whoops!
-- alter table data.ow_leveldata_raw
-- add constraint ow_leveldata_ow_validity CHECK (fieldwork.ow_exists(ow_uid) = true) NOT VALID;

-- alter table data.gw_depthdata_raw
-- add constraint gw_depthdata_ow_validity CHECK (fieldwork.ow_exists(ow_uid) = true) NOT VALID;

-- alter table fieldwork.well_measurements
-- add constraint ow_validity CHECK (fieldwork.ow_exists(ow_uid) = true) NOT VALID;

-- alter table metrics.draindown
-- add constraint ow_validity CHECK (fieldwork.ow_exists(ow_uid) = true) NOT VALID;

-- alter table metrics.infiltration
-- add constraint ow_validity CHECK (fieldwork.ow_exists(ow_uid) = true) NOT VALID;

-- alter table metrics.overtopping
-- add constraint ow_validity CHECK (fieldwork.ow_exists(ow_uid) = true) NOT VALID;

-- alter table metrics.percentstorage
-- add constraint ow_validity CHECK (fieldwork.ow_exists(ow_uid) = true) NOT VALID;

-- alter table metrics.snapshot
-- add constraint ow_validity CHECK (fieldwork.ow_exists(ow_uid) = true) NOT VALID;

-- alter table metrics.snapshot_metadata
-- add constraint ow_validity CHECK (fieldwork.ow_exists(ow_uid) = true) NOT VALID;

-- ------
-- alter table data.ow_leveldata_raw
-- drop constraint ow_leveldata_ow_validity

-- alter table data.gw_depthdata_raw
-- drop constraint gw_depthdata_ow_validity

-- alter table fieldwork.well_measurements
-- drop constraint ow_validity

-- alter table metrics.draindown
-- drop constraint ow_validity

-- alter table metrics.infiltration
-- drop constraint ow_validity

-- alter table metrics.overtopping
-- drop constraint ow_validity

-- alter table metrics.percentstorage
-- drop constraint ow_validity

-- alter table metrics.snapshot
-- drop constraint ow_validity

-- alter table metrics.snapshot_metadata
-- drop constraint ow_validity


---trying again, but with ow_uid_fkey
alter table data.ow_leveldata_raw
add constraint ow_uid_fkey FOREIGN KEY (ow_uid)
        REFERENCES fieldwork.ow (ow_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE no action;

alter table data.gw_depthdata_raw
add constraint ow_uid_fkey FOREIGN KEY (ow_uid)
        REFERENCES fieldwork.ow (ow_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE no action;

alter table fieldwork.well_measurements
add constraint ow_uid_fkey FOREIGN KEY (ow_uid)
        REFERENCES fieldwork.ow (ow_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE no action;

alter table metrics.draindown
add constraint ow_uid_fkey FOREIGN KEY (ow_uid)
        REFERENCES fieldwork.ow (ow_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE no action;

alter table metrics.infiltration
add constraint ow_uid_fkey FOREIGN KEY (ow_uid)
        REFERENCES fieldwork.ow (ow_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE no action;

alter table metrics.overtopping
add constraint ow_uid_fkey FOREIGN KEY (ow_uid)
        REFERENCES fieldwork.ow (ow_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE no action;

alter table metrics.percentstorage
add constraint ow_uid_fkey FOREIGN KEY (ow_uid)
        REFERENCES fieldwork.ow (ow_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE no action;

alter table metrics.snapshot
add constraint ow_uid_fkey FOREIGN KEY (ow_uid)
        REFERENCES fieldwork.ow (ow_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE no action;

alter table metrics.snapshot_metadata
add constraint ow_uid_fkey FOREIGN KEY (ow_uid)
        REFERENCES fieldwork.ow (ow_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE no action;

alter table fieldwork.deployment
add constraint ow_uid_fkey FOREIGN KEY (ow_uid)
        REFERENCES fieldwork.ow (ow_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE no action;

alter table fieldwork.future_deployment
add constraint ow_uid_fkey FOREIGN KEY (ow_uid)
        REFERENCES fieldwork.ow (ow_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE no action;

alter table admin.accessdb
add constraint ow_uid_fkey FOREIGN KEY (ow_uid)
        REFERENCES fieldwork.ow (ow_uid) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE no action;


----

-- add constraint for research lookup uid to fieldwork.deployment 

-- add site name constraints fkeys to fieldwork that has those? 