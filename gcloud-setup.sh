export GOOGLE_CLOUD_PROJECT=<add project id>
export GOOGLE_BILLING_ACCT=<add billing account>
export GOOGLE_STORAGE_BUCKET=$GOOGLE_CLOUD_PROJECT_bfro_data
gcloud info
gcloud projects create $GOOGLE_CLOUD_PROJECT --labels=env=dev
gcloud config set project $GOOGLE_CLOUD_PROJECT
echo Find the Billing Acccounts....
gcloud alpha billing accounts list
gcloud beta billing projects link $GOOGLE_CLOUD_PROJECT --billing-account=$GOOGLE_BILLING_ACCT

gcloud services enable compute.googleapis.com bigquery.googleapis.com bigquerystorage.googleapis.com \
bigquerydatatransfer.googleapis.com  cloudapis.googleapis.com cloudfunctions.googleapis.com \
elevation-backend.googleapis.com pubsub.googleapis.com run.googleapis.com storage-api.googleapis.com \
storage-component.googleapis.com storage.googleapis.com

gcloud iam service-accounts create terraform-service-acct --display-name="Terraform Service Account"
gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT --member='serviceAccount:terraform-service-acct@msd86
54-434-bfro-dev.iam.gserviceaccount.com' --role='roles/editor'

gcloud iam service-accounts keys create terraform-service-acct-key.json \
 --iam-account=terraform-service-acct@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com


