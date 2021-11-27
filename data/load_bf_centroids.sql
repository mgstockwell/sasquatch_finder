CREATE OR REPLACE TABLE
  `msd8654-434.bfro.bf_centroids` AS
SELECT  
  base.*,
  bf.CENTROID_ID AS CENTROID_ID,
  CASE bf.CENTROID_ID
    WHEN 1 THEN 'red'
    WHEN 2 THEN 'orange'
    WHEN 3 THEN 'pink'
    WHEN 4 THEN 'green'
    WHEN 5 THEN 'blue'
  ELSE
  'darkpurple'
END
  AS CENTROID_COLOR,
  fit.sum_all_distance,
  fit.fit_rating
FROM
  `bfro.bfro_reports_geocoded_final` AS base
INNER JOIN
  ML.PREDICT(MODEL `bfro.bf_sighting_clusters`,
    TABLE `msd8654-434.bfro.bfro_reports_geocoded_final`) bf
ON
  base.number=bf.number
INNER JOIN (
  SELECT distinct 
    bf.number,
    d.CENTROID_ID,
    d.DISTANCE,
    SUM(d.distance) OVER (PARTITION BY CAST(bf.number AS int)) sum_all_distance,
    1 - (d.DISTANCE/ SUM(d.distance) OVER (PARTITION BY CAST(bf.number AS int))) fit_rating
  FROM
    ML.PREDICT(MODEL `msd8654-434.bfro.bf_sighting_clusters`,
      TABLE `msd8654-434.bfro.bfro_reports_geocoded_final`) bf
  CROSS JOIN
    UNNEST(NEAREST_CENTROIDS_DISTANCE) d) fit
ON
  bf.number=fit.number and bf.CENTROID_ID=fit.CENTROID_ID
  ;
