import datadotworld as dw
# documentation: https://docs.data.world/en/59261-59632-1--Python-SDK.html
bfro_dataset = dw.load_dataset('timothyrenner/bfro-sightings-data')
print(bfro_dataset.describe())


# https://cloud.google.com/bigquery/docs/loading-data-cloud-storage-csv
from google.cloud import bigquery

# Construct a BigQuery client object.
client = bigquery.Client()

# TODO(developer): Set table_id to the ID of the table to create.
# table_id = "your-project.your_dataset.your_table_name"

job_config = bigquery.LoadJobConfig(
    schema=[
        bigquery.SchemaField("name", "STRING"),
        bigquery.SchemaField("post_abbr", "STRING"),
    ],
    skip_leading_rows=1,
    # The source format defaults to CSV, so the line below is optional.
    source_format=bigquery.SourceFormat.CSV,
)
uri = "gs://cloud-samples-data/bigquery/us-states/us-states.csv"

load_job = client.load_table_from_uri(
    uri, table_id, job_config=job_config
)  # Make an API request.

load_job.result()  # Waits for the job to complete.

destination_table = client.get_table(table_id)  # Make an API request.
print("Loaded {} rows.".format(destination_table.num_rows))

# https://www.thecodebuzz.com/python-upload-files-download-files-google-cloud-storage/
from google.cloud import storage 
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