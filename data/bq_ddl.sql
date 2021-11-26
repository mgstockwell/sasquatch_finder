CREATE OR REPLACE VIEW
  `bfro.precip_by_county_vv` AS
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
  `msd8654-434.bfro.climdiv-pcpncy` ;
