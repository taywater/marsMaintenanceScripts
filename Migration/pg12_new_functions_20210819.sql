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

