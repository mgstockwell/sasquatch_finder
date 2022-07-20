CREATE OR REPLACE VIEW bfro.precip_by_county_vv AS
SELECT
  /* https://www.ncei.noaa.gov/pub/data/cirs/climdiv/county-readme.txt */
  #STATE-CODE          1-2      STATE-CODE as indicated in State Code Table as
  #                             described in FILE 1.  Range of values is 01-48.
  SUBSTR(string_field_0, 1,2) AS state_code,
  #DIVISION-NUMBER     3-5      COUNTY FIPS - Range of values 001-999.
  #Need Code translation see https://www.ncei.noaa.gov/pub/data/cirs/climdiv/county-readme.txt
  #The state code in noaa not same as FIPS state code, why would they do that
  CONCAT(
    CASE SUBSTR(string_field_0, 1,2)
      WHEN '01' THEN '01'
      WHEN '50' THEN '02'
      WHEN '02' THEN '04'
      WHEN '03' THEN '05'
      WHEN '04' THEN '06'
      WHEN '05' THEN '08'
      WHEN '06' THEN '09'
      WHEN '007' THEN '10'
      WHEN '08' THEN '12'
      WHEN '09' THEN '13'
      WHEN '10' THEN '16'
      WHEN '11' THEN '17'
      WHEN '12' THEN '18'
      WHEN '13' THEN '19'
      WHEN '14' THEN '20'
      WHEN '15' THEN '21'
      WHEN '16' THEN '22'
      WHEN '17' THEN '23'
      WHEN '18' THEN '24'
      WHEN '19' THEN '25'
      WHEN '20' THEN '26'
      WHEN '21' THEN '27'
      WHEN '22' THEN '28'
      WHEN '23' THEN '29'
      WHEN '24' THEN '30'
      WHEN '25' THEN '31'
      WHEN '26' THEN '32'
      WHEN '27' THEN '33'
      WHEN '28' THEN '34'
      WHEN '29' THEN '35'
      WHEN '30' THEN '36'
      WHEN '31' THEN '37'
      WHEN '32' THEN '38'
      WHEN '33' THEN '39'
      WHEN '34' THEN '40'
      WHEN '35' THEN '41'
      WHEN '36' THEN '42'
      WHEN '37' THEN '44'
      WHEN '38' THEN '45'
      WHEN '39' THEN '46'
      WHEN '40' THEN '47'
      WHEN '41' THEN '48'
      WHEN '42' THEN '49'
      WHEN '43' THEN '50'
      WHEN '44' THEN '51'
      WHEN '45' THEN '53'
      WHEN '46' THEN '54'
      WHEN '47' THEN '55'
      WHEN '48' THEN '56'
    ELSE
    '00'
  END
    , SUBSTR(string_field_0, 3,3) ) AS county_fips,
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
  `bfro.climdiv-pcpncy`
  
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
