# sasquatch_finder
ML project to predict likelihood of finding Bigfoot in a particular area.

[![CircleCI](https://circleci.com/gh/mgstockwell/sasquatch_finder.svg?style=svg)](https://app.circleci.com/pipelines/github/mgstockwell/sasquatch_finder)
=======
## Overview
This is a Google Cloud Platform (GCP) based project using BigQueryML to classify bigfoot (aka sasquatch) sightings by climate, precipitation, elevation, and population density. The hypothesis is that there are different subspecies of the North American Ape with distinct ranges (see [Sasquatch Field Guide](https://www.amazon.com/Sasquatch-Field-Gde-J-Meldrum/dp/193719695X).

## Source Data
Source data derived from the geo database of sightings at [BRFO - Bigfoot Research Org](https://www.bfro.net/gdb/)

Data cleaned up and appended by data.world user [@timothyrenner](https://data.world/timothyrenner) (thank you!) and hosted at https://data.world/timothyrenner/bfro-sightings-data using code from https://github.com/timothyrenner/bfro_sightings_data.

Precipitation data is pulled from NOAA at https://www.ncei.noaa.gov/pub/data/cirs/climdiv/. Zipcode and population data is pulled from 
bigquery-public-data:census_bureau_usa.population_by_zip_2010 , bigquery-public-data:geo_us_boundaries.zip_codes , and bigquery-public-data:geo_us_boundaries.counties.  The [Google Elevation API](https://developers.google.com/maps/documentation/elevation/start) is used to append elevation to lat/long locations.  For climate data, Plant Hardiness Zones are used as a proxy, with code available at https://github.com/waldoj/frostline (thank you!)

