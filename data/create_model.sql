CREATE OR REPLACE MODEL
  bfro.bf_sighting_clusters OPTIONS(model_type='kmeans',
    num_clusters=6) AS
SELECT
  state,
  elevation,
  hardiness_zone_num,
  yearly_precipitation,
  pop_density_sqkm
FROM
  `bfro.bfro_reports_geocoded_final`;
