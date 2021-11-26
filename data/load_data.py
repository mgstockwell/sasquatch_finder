from google.cloud import storage
import datadotworld as dw
import json
from google.cloud import bigquery
import urllib.request
import os

# if running locally will need app credentials 
# terminal
# GOOGLE_APPLICATION_CREDENTIALS=<path>/<filename>.json
# powershell:
# $env:GOOGLE_APPLICATION_CREDENTIALS="<path>/<filename>.json"

# documentation: https://docs.data.world/en/59261-59632-1--Python-SDK.html
bfro_dataset = dw.load_dataset('timothyrenner/bfro-sightings-data')
print(json.dumps(bfro_dataset.describe(), indent=4))
csv_file = bfro_dataset.rawdata()

# https://www.thecodebuzz.com/python-upload-files-download-files-google-cloud-storage/
def upload_blob(bucket_name, source_file_name, destination_blob_name):
    """Uploads a file to the google storage bucket."""

    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(destination_blob_name)

    blob.upload_from_filename(source_file_name)

    print(
        "File {} uploaded to Storage Bucket with Bob name  {} successfully .".format(
            source_file_name, destination_blob_name
        )
    )

# function to load a csv to BQ directly
# https://cloud.google.com/bigquery/docs/loading-data-cloud-storage-csv
# https://cloud.google.com/bigquery/docs/batch-loading-data
def load_bq_table(file_name, table_id, skip_rows=1):
    # Construct a BigQuery client object.
    client = bigquery.Client()
    job_config = bigquery.LoadJobConfig(
    source_format=bigquery.SourceFormat.CSV, skip_leading_rows=0, autodetect=True)

    urllib.request.urlretrieve(source_url, file_name)

    with open(file_name, "rb") as source_file:
        job = client.load_table_from_file(source_file, table_id, job_config=job_config)
        source_file.close()
        os.remove(file_name)

    job.result()  # Waits for the job to complete.

    table = client.get_table(table_id)  # Make an API request.
    print(
        "Loaded {} rows and {} columns to {}".format(
            table.num_rows, len(table.schema), table_id
        )
    )

# load dataset to storage bucket
df = bfro_dataset.dataframes.get("bfro_reports_geocoded")
upload_blob('bfro_data', df.to_csv(index=False) ,
            'bfro_reports_geocoded.csv')

# climate data by county, see https://www.ncei.noaa.gov/pub/data/cirs/climdiv/county-readme.txt
# note the source file is position delimited, will appear as one column
# TODO: data on climate changes monthly, need to get filename dynamically
table_id = "bfro.climdiv-pcpncy"
source_url = "https://www.ncei.noaa.gov/pub/data/cirs/climdiv/climdiv-pcpncy-v1.0.0-20211104"
file_name = "climdiv-pcpncy"

urllib.request.urlretrieve(source_url, file_name)
load_bq_table(file_name,table_id,skip_rows=0)
