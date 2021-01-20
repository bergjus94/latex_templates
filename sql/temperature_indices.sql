-- Script for calculating indices for every time series measured this year

-- calculating mean temperature for the whole time series

DROP VIEW IF EXISTS mean_temperature;
CREATE VIEW mean_temperature AS
SELECT avg(data.value) AS t_avg,
    d.device_id AS hobo_id
FROM (data
JOIN metadata d ON ((data.meta_id = d.id)))
WHERE (d.term_id = 11)
GROUP BY d.device_id
ORDER BY d.device_id;
SELECT * FROM mean_temperature;

-- calculating mean day temperature t_d

DROP VIEW IF EXISTS mean_day_temperature CASCADE;
CREATE VIEW mean_day_temperature AS
SELECT 
	avg(data.value) as t_d,
	d.device_id as HOBO_ID
FROM data
JOIN metadata d ON data.meta_id=d.id
WHERE d.term_id=11
AND (EXTRACT(HOUR FROM data.tstamp) >= 6)
AND (EXTRACT(HOUR FROM data.tstamp) < 18)
GROUP BY d.device_id
ORDER BY d.device_id ASC;
SELECT * FROM mean_day_temperature;

-- calculating mean night temperature t_n

DROP VIEW IF EXISTS mean_night_temperature CASCADE;
CREATE VIEW mean_night_temperature AS
SELECT 
	avg(data.value) as t_n,
	d.device_id as HOBO_ID
FROM data
JOIN metadata d ON data.meta_id=d.id
WHERE d.term_id=11
AND (EXTRACT(HOUR FROM data.tstamp) <= 5)
OR (EXTRACT(HOUR FROM data.tstamp) >=18)
GROUP BY d.device_id
ORDER BY d.device_id ASC;
SELECT * FROM mean_night_temperature;

-- calculating the Difference between mean day and night temperature t_nd

DROP VIEW IF EXISTS diff_mean_daynight CASCADE;
CREATE VIEW diff_mean_daynight AS
SELECT 
	d.t_d,
	d.hobo_id,
	n.t_n,
	(d.t_d-n.t_n) as t_nd 
FROM mean_day_temperature d
JOIN mean_night_temperature n ON d.hobo_id=n.hobo_id; 
SELECT * FROM diff_mean_daynight;

-- putting all views in one indices table and viewing whole table

DROP TABLE IF EXISTS indices CASCADE;
CREATE TABLE indices AS
SELECT
	diff.hobo_id, t_d, t_n, t_nd,
	m.t_avg
FROM diff_mean_daynight diff
JOIN mean_temperature m ON diff.hobo_id=m.hobo_id;
SELECT * FROM indices;
