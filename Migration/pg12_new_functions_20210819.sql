pg12_new_functions_20210819

#20210819
#ow_exists
#DROPPED THIS WHEN I REMEMBERED I COULD FKEY
-- CREATE OR REPLACE FUNCTION fieldwork.ow_exists(
-- 	thisow integer)
--     RETURNS boolean
--     LANGUAGE 'sql'

--     COST 100
--     VOLATILE 
-- AS $BODY$SELECT EXISTS (SELECT TRUE FROM fieldwork.ow WHERE ow_uid = thisow)

-- $BODY$;

-- drop function fieldwork.ow_exists

#20210820
#event depth functions
CREATE OR REPLACE FUNCTION metrics.event_depth_bin(
	eventdepth_in numeric)
    RETURNS integer
    LANGUAGE 'sql'

    COST 100
    VOLATILE 
AS $BODY$
SELECT 
CASE
WHEN eventdepth_in < 0.5 THEN 1
WHEN eventdepth_in < 1 THEN 2
WHEN eventdepth_in < 1.5 THEN 3 
WHEN eventdepth_in < 2 THEN 4
WHEN eventdepth_in < 3 THEN 5
ELSE 6
END;
$BODY$;

CREATE OR REPLACE FUNCTION metrics.event_depth_bin_relative(
	eventdepth_in numeric,
	designdepth_in numeric)
    RETURNS integer
    LANGUAGE 'sql'

    COST 100
    VOLATILE 
AS $BODY$
SELECT 
CASE
WHEN eventdepth_in - designdepth_in > -0.25 AND eventdepth_in - designdepth_in < 0.25 THEN 3
WHEN eventdepth_in - designdepth_in >= 0.25 AND eventdepth_in - designdepth_in < 0.75 THEN 4
WHEN eventdepth_in - designdepth_in >= 0.75 AND eventdepth_in - designdepth_in < 1.25 THEN  5
WHEN eventdepth_in - designdepth_in <= -0.25 AND eventdepth_in - designdepth_in > -0.75 THEN 2
WHEN eventdepth_in - designdepth_in <= -0.75 AND eventdepth_in - designdepth_in > -1.25 THEN 1
ELSE 6
END;
$BODY$;

--20210824 
-- fieldwork
-- fieldwork.installation_height
CREATE OR REPLACE FUNCTION fieldwork.installation_height_ft(
    sensor_one_inch_off_bottom boolean,
    well_depth_ft numeric,
    cap_to_hook_ft numeric,
    hook_to_sensor_ft numeric)
    RETURNS numeric
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$   BEGIN 
    if sensor_one_inch_off_bottom = TRUE then 
    return(1/12); 
    else 
    return(well_depth_ft - cap_to_hook_ft - hook_to_sensor_ft);
    end if;
END;
$BODY$;

-- fieldwork.orifice_to_sensor_ft
CREATE OR REPLACE FUNCTION fieldwork.orifice_to_sensor_ft(
    sensor_one_inch_off_bottom boolean,
    weir boolean,
    well_depth_ft numeric,
    cap_to_hook_ft numeric,
    hook_to_sensor_ft numeric,
    cap_to_orifice_ft numeric)
    RETURNS numeric
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$   BEGIN 
    if weir = TRUE then
        if sensor_one_inch_off_bottom = TRUE then
        return(well_depth_ft - 1/12 - cap_to_orifice_ft);
        else 
        return(cap_to_hook_ft + hook_to_sensor_ft - cap_to_orifice_ft);
        end if;
        else return(NULL);
        end if;
        END;
        $BODY$;

-- fieldwork.public_private
CREATE OR REPLACE FUNCTION fieldwork.public_private(
    private_smp_id text)
    RETURNS boolean
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$
 BEGIN
 if private_smp_id is NULL then 
 return(TRUE); 
 else
 return(FALSE);
 end if;
 END;
 $BODY$;

-- fieldwork.sensor_isnt_deployed
CREATE OR REPLACE FUNCTION fieldwork.sensor_isnt_deployed(
    thissensoruid integer,
    thisdeploymentuid integer,
    thiscollectiondate timestamp with time zone)
    RETURNS boolean
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$DECLARE 
    tabledeploymentuid integer := deployment_uid FROM fieldwork.deployment WHERE deployment_uid = thisdeploymentuid; 
BEGIN
IF thiscollectiondate IS NOT NULL THEN
    RETURN TRUE;
ELSIF tabledeploymentuid = thisdeploymentuid THEN
    RETURN TRUE;
ELSE RETURN(SELECT not exists (SELECT * FROM fieldwork.deployment WHERE inventory_sensors_uid = thissensoruid AND collection_dtime_est IS NULL));
END IF;
END;
$BODY$;

-- fieldwork.weir_to_orifice_ft
CREATE OR REPLACE FUNCTION fieldwork.weir_to_orifice_ft(
    weir boolean,
    cap_to_weir_ft numeric,
    cap_to_orifice_ft numeric)
    RETURNS numeric
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$
    BEGIN 
    if weir = TRUE  then
        return(cap_to_orifice_ft - cap_to_weir_ft);
        else 
        return(NULL);
        end if;
        END;
        $BODY$;


-- fieldwork.weir_to_sensor_ft
CREATE OR REPLACE FUNCTION fieldwork.weir_to_sensor_ft(
    sensor_one_inch_off_bottom boolean,
    weir boolean,
    well_depth_ft numeric,
    cap_to_hook_ft numeric,
    hook_to_sensor_ft numeric,
    cap_to_weir_ft numeric)
    RETURNS numeric
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$   BEGIN 
    if weir = TRUE then
        if sensor_one_inch_off_bottom = TRUE then
        return(well_depth_ft - 1/12 - cap_to_weir_ft);
        else 
        return(cap_to_hook_ft + hook_to_sensor_ft - cap_to_weir_ft);
        end if;
        else return(NULL);
        end if;
        END;
        $BODY$;


-- draindown boolean
CREATE OR REPLACE FUNCTION metrics.draindown_boolean(
    draindown_hr numeric,
    rel_percentstorage numeric,
    eventdepth_in numeric)
    RETURNS boolean
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$ 
    BEGIN 
        IF draindown_hr > 72 AND response_boolean(rel_percentstorage, eventdepth_in) = TRUE THEN 
        RETURN FALSE;
        ELSIF draindown_hr <= 72 AND response_boolean(rel_percentstorage, eventdepth_in) = TRUE THEN
        RETURN TRUE; 
        ELSE
        RETURN NULL;
        END IF;
    END;
    $BODY$;

-- response boolean
CREATE OR REPLACE FUNCTION metrics.response_boolean(
    rel_percentstorage numeric,
    eventdepth_in numeric)
    RETURNS boolean
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$
BEGIN
    IF eventdepth_in >= 1 AND rel_percentstorage >= 15 THEN 
    RETURN TRUE;
    ELSIF eventdepth_in >= 1 AND rel_percentstorage < 15 THEN 
    RETURN FALSE;
    ELSE 
    RETURN NULL;
    END IF;
END;
$BODY$;