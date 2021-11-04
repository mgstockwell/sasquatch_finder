from google.cloud import storage
import datadotworld as dw
import json
from google.cloud import bigquery
import urllib.request
import os

# GOOGLE_APPLICATION_CREDENTIALS=c:\tmp\msd8654-434-c23b2877795f.json
# powershell:
# $env:GOOGLE_APPLICATION_CREDENTIALS="c:\tmp\msd8654-434-c23b2877795f.json"

# documentation: https://docs.data.world/en/59261-59632-1--Python-SDK.html
bfro_dataset = dw.load_dataset('timothyrenner/bfro-sightings-data')
print(json.dumps(bfro_dataset.describe(), indent=4))


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


upload_blob('bfro_data', 'C:/Users/marks/.dw/cache/timothyrenner/bfro-sightings-data/latest/data/bfro_reports_geocoded.csv',
            'bfro_reports_geocoded.csv')

#############################################################################  Load BQ
# https://cloud.google.com/bigquery/docs/loading-data-cloud-storage-csv
# https://cloud.google.com/bigquery/docs/batch-loading-data

# Construct a BigQuery client object.
client = bigquery.Client()

# TODO(developer): add project id, dataset env variables
table_id = "bfro.climdiv-pcpncy"
source_url = "https://www.ncei.noaa.gov/pub/data/cirs/climdiv/climdiv-pcpncy-v1.0.0-20211006"
file_name = "climdiv-pcpncy"

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
