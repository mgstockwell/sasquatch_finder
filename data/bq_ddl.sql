CREATE OR REPLACE VIEW bfro.precip_by_county_vv AS
SELECT
  /* https://www.ncei.noaa.gov/pub/data/cirs/climdiv/county-readme.txt */
  #STATE-CODE          1-2      STATE-CODE as indicated in State Code Table as
  #                             described in FILE 1.  Range of values is 01-48.
  SUBSTR(string_field_0, 1,2) AS state_code,
  #DIVISION-NUMBER     3-5      COUNTY FIPS - Range of values 001-999.
  SUBSTR(string_field_0, 3,3) AS county_fips,
  #ELEMENT CODE        6-7      01 = Precipitation
  #                             02 = Average Temperature
  #                             27 = Maximum Temperature
  #                             28 = Minimum Temperature
  SUBSTR(string_field_0, 6,2) AS element_code,
  #YEAR                8-11     This is the year of record.  Range is 1895 to
  #current year processed.
  SUBSTR(string_field_0, 8,4) AS year,
  #Monthly Divisional Temperature format (f7.2)
  #Range of values -50.00 to 140.00 degrees Fahrenheit.
  #Decimals retain a position in the 7-character
  #field.  Missing values in the latest year are
  #indicated by -99.99. (all data values are right justified):
  CAST(SUBSTR(string_field_0, 12, 6) AS FLOAT64) AS jan_value,
  CAST(SUBSTR(string_field_0, 19, 6) AS FLOAT64) AS feb_value,
  CAST(SUBSTR(string_field_0, 26, 6) AS FLOAT64) AS mar_value,
  CAST(SUBSTR(string_field_0, 33, 6) AS FLOAT64) AS apr_value,
  CAST(SUBSTR(string_field_0, 40, 6) AS FLOAT64) AS may_value,
  CAST(SUBSTR(string_field_0, 47, 6) AS FLOAT64) AS june_value,
  CAST(SUBSTR(string_field_0, 54, 6) AS FLOAT64) AS july_value,
  CAST(SUBSTR(string_field_0, 61, 6) AS FLOAT64) AS aug_value,
  CAST(SUBSTR(string_field_0, 68, 6) AS FLOAT64) AS sept_value,
  CAST(SUBSTR(string_field_0, 75, 6) AS FLOAT64) AS oct_value,
  CAST(SUBSTR(string_field_0, 82, 6) AS FLOAT64) AS nov_value,
  CAST(SUBSTR(string_field_0, 89, 6) AS FLOAT64) AS dec_value
FROM
  `bfro.climdiv-pcpncy`;
  
CREATE OR REPLACE EXTERNAL TABLE bfro.bfro_reports_geocoded_csv
OPTIONS (
  format = 'CSV',
  uris = ['gs://bfro_data/bfro_reports_geocoded.csv']
)
;

CREATE OR REPLACE TABLE
  `bfro.bfro_reports_geocoded_final` AS
SELECT
  base.*,
  ST_GEOGPOINT(base.longitude,
    base.latitude) geogpoint,
  zip.zip_code,
  zip.area_land_meters,
  uscb.population,
  ROUND(uscb.population/(zip.area_land_meters/1000000)) pop_density_sqkm,
  counties.county_fips_code,
  zip.county AS zip_county,
  zip.state_fips_code,
  zip.state_code,
  zip.state_name,
  hz.zone AS hardiness_zone_code,
  LEFT(zone,LENGTH(zone)-1) hardiness_zone_num,
  elevations.elevation,
  pcp.yearly_precipitation
FROM
  `bfro.bfro_reports_geocoded_csv` AS base
INNER JOIN (
  SELECT
    geo.number,
    z.zip_code,
    CAST(z.zip_code AS int64) AS zip_code_int64,
    z.area_land_meters,
    z.county,
    z.state_fips_code,
    z.state_code,
    z.state_name
  FROM
    `bigquery-public-data.geo_us_boundaries.zip_codes` AS z,
    `bfro.bfro_reports_geocoded_csv` geo
  WHERE
    ST_WITHIN(ST_GEOGPOINT(geo.longitude,
        geo.latitude),
      z.zip_code_geom) ) AS zip
ON
  base.number=zip.number
LEFT OUTER JOIN
  `bigquery-public-data.census_bureau_usa.population_by_zip_2010` AS uscb
ON
  CAST(uscb.zipcode AS int64)=zip.zip_code_int64
  AND uscb.gender IS NULL
LEFT OUTER JOIN
  `bfro.hardiness_zones` AS hz
ON
  hz.zip_code=zip.zip_code_int64
LEFT OUTER JOIN
  `bigquery-public-data.geo_us_boundaries.counties` counties
ON
  trim(lower(REPLACE(SPLIT(zip.county)[
  OFFSET
    (0)],'County','')))=trim(lower(REPLACE(counties.county_name,'County','')))
  AND cast(zip.state_fips_code as int64)=cast(counties.state_fips_code as int64)
LEFT OUTER JOIN (
  SELECT
    year,
    county_fips,
    ROUND(jan_value + feb_value + mar_value + apr_value + may_value + june_value 
    + july_value + aug_value + sept_value + oct_value + nov_value + dec_value) AS yearly_precipitation
  FROM
    `bfro.precip_by_county_vv`) pcp
ON
  CAST(counties.county_fips_code AS int64)=CAST(pcp.county_fips AS int64)
  AND EXTRACT(YEAR
  FROM
    base.date)=pcp.year
LEFT OUTER JOIN
  `bfro.elevations` elevations
ON
  elevations.number=base.number;
