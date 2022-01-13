# Sasquatch Classification Model
ML project to predict likelihood of finding Bigfoot in a particular area.

[![CircleCI](https://circleci.com/gh/mgstockwell/sasquatch_finder.svg?style=svg)](https://app.circleci.com/pipelines/github/mgstockwell/sasquatch_finder)
=======
## Project Overview

Author: 	Mark Stockwell [MarkStockwell2021@u.northwestern.edu](mailto:MarkStockwell2021@u.northwestern.edu) 

Updated:	November 28, 2021

This is a Google Cloud Platform (GCP) based project using BigQueryML to classify bigfoot (aka sasquatch) sightings by climate, precipitation, elevation, and population density. The hypothesis is that there are different subspecies of the North American Ape with distinct ranges, see [Sasquatch Field Guide](https://www.amazon.com/Sasquatch-Field-Gde-J-Meldrum/dp/193719695X).

## **Introduction**

The [North American Wood Ape](https://www.woodape.org/) (aka “Sasquatch”, “Bigfoot”) may exist and many legitimate scientists are actively researching the possibility[^1]. The [Bigfoot Field Researchers Organization](https://www.bfro.net/)[^2] has been collecting and analyzing reports of sightings from credible witnesses for several decades. Historians note that Native American peoples have centuries old oral traditions of large hominids with multiple descriptions depending on geographic region[^3]. It is likely that distinct populations exist[^4] and can be classified based on geographic features.


## **Goals & Objectives**

The goal of this project is to build a Machine Learning model using the Google Cloud Platform that classifies bigfoot sightings based on location, elevation, climate, and population. Analyze the predictive power of the model and develop visualizations of data using open source tools.


## Data Sources


*   [Bigfoot sightings database](https://www.bfro.net/GDB/#usa) - This is a curated collection of sightings with location information and will be the primary source. This data has been standardized and enhanced at [data.world/timothyrenner/bfro-sightings-data](https://data.world/timothyrenner/bfro-sightings-data/workspace/file?filename=bfro_reports_geocoded.csv) (thank you!)
*   Precipitation data by county, available from the [National Oceanic Atmospheric Agency](https://www.ncei.noaa.gov/pub/data/cirs/climdiv/).
*   Population data by zip code and county from the [US Census Bureau.](https://www.census.gov/data.html) 
*   Elevation data via the [Google Elevation API](https://developers.google.com/maps/documentation/elevation/start).
*   Plant Hardiness Zones are used as a proxy for temperature, code available at [waldoj/frostline: A dataset, API, and parser for USDA plant hardiness zones.](https://github.com/waldoj/frostline) (thank you!)
*   Zipcode and population data is pulled from 
bigquery-public-data:census_bureau_usa.population_by_zip_2010 , bigquery-public-data:geo_us_boundaries.zip_codes , and bigquery-public-data:geo_us_boundaries.counties.  


## Data Architecture

Data is ingested from original sources or derived from an API, see below:


*   BFRO data is loaded to Cloud storage via python [load.py](https://github.com/mgstockwell/sasquatch_finder/blob/main/data/load_data.py) script from data.world.
*   Precipitation data is loaded directly to a one column BigQuery table in raw/space delimited format via the load.py script and then converted to structured data using a [view](https://github.com/mgstockwell/sasquatch_finder/blob/main/data/bq_ddl.sql)
*   Population data is accessed live as needed from [bigquery-public-data:census\_bureau\_usa.population\_by\_zip\_2010](https://console.cloud.google.com/bigquery?cloudshell=false&d=census_bureau_usa&p=bigquery-public-data&t=population_by_zip_2010) 
*   Zip code data is from [bigquery-public-data:geo\_us\_boundaries.zip\_codes](https://console.cloud.google.com/bigquery?cloudshell=false&d=geo_us_boundaries&p=bigquery-public-data&t=zip_codes) 
*   Elevation data is loaded from a csv into the storage bucket via a Jupyter notebook utility [Elevation\_API.ipynb](https://github.com/mgstockwell/sasquatch_finder/blob/main/Elevation_API.ipynb) 

Once raw data is imported into the project, a DDL script creates the [bfro\_reports\_geocoded\_final](https://github.com/mgstockwell/sasquatch_finder/blob/main/data/bq_ddl.sql) table which includes yearly precipitation, elevation, location, zip code, county, population density, and all other attributes in a single wide table. This table is then used as a source for a [BigQueryML model](https://github.com/mgstockwell/sasquatch_finder/blob/main/data/create_model.sql). The [ML.PREDICT](https://cloud.google.com/bigquery-ml/docs/reference/standard-sql/bigqueryml-syntax-predict) function is used to create the [bf\_centroids table](https://github.com/mgstockwell/sasquatch_finder/blob/main/data/load_bf_centroids.sql), which has a cluster identifier for each Bigfoot sighting and the distance to the centroid for all centroids. The distance of the best match centroid is assigned a fit\_rating percentage based on the distance to centroid vs total distance of all centroids. The fit\_rating can be used in predictions to determine the best centroid match and quality for a random point.

Visualizations are done using a folium map hosted on Google App Engine ([main.py](https://github.com/mgstockwell/sasquatch_finder/blob/main/main.py)). Each sighting with associated data is color coded to the centroid, with data filtered by fit\_rating.


## **System Maintenance & Operations**

Source data changes slowly, on the order of days for base BFRO data. The data however is sourced from data.world, which is updated monthly. Suggested maintenance window is daily check for updated data, and if found then rerun the data load, model creation, and final analytical table creation.  Additional alerts should be set up and monitored for app engine latency and errors.  Over time updates to the python version and related packages may be needed similar to other systems.


## **Future Enhancements**

The current architecture relies heavily on the data.world dataset. This could be bypassed by going directly to bfro.org data.  Some sightings have coarse location (i.e. county) but are missing lat/long. These could be enhanced to use the county center location. County to zip code translation has some errors due to zip codes overlapping county boundaries. This could be corrected by using the center of the zip code polygon to determine the county. Zip code and county data also contain percentage of coverage by water; this could be added to the list of features.


<!-- Footnotes themselves at the bottom. -->
## Notes

[^1]:
     Meldrum, 2016 [Sasquatch & Other Wildmen: The Search for Relict Hominoids](https://journalofscientificexploration.org/index.php/jse/article/view/1090) 

[^2]:
     See https://www.bfro.net/ 

[^3]:
     The RELICT HOMINOID INQUIRY 1:1-12 (2012) , see https://www.isu.edu/rhi/research-papers/ 

[^4]:
     See https://en.wikipedia.org/wiki/Skunk_ape 

