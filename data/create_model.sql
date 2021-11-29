CREATE OR REPLACE MODEL
  bfro.bf_sighting_clusters OPTIONS(model_type='KMEANS',
    KMEANS_INIT_METHOD = 'KMEANS++',
    STANDARDIZE_FEATURES = TRUE,
    num_clusters=6) AS
SELECT
  latitude,
  longitude,
  zip_code,
  state_code,
  elevation,
  hardiness_zone_num,
  yearly_precipitation,
  pop_density_sqkm
FROM
  `bfro.bfro_reports_geocoded_final`;
