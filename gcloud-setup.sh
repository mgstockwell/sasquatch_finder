export GOOGLE_CLOUD_PROJECT=msd8654-434-bfro-dev
export GOOGLE_BILLING_ACCT=01278E-34A2F6-83795E
gcloud info
gcloud projects create msd8654-434-bfro-dev --labels=env=dev
gcloud config set project msd8654-434-bfro-dev
echo Find the Billing Acccounts....
gcloud alpha billing accounts list
gcloud beta billing projects link msd8654-434-bfro-dev --billing-account=01278E-34A2F6-83795E

gcloud services enable compute.googleapis.com bigquery.googleapis.com bigquerystorage.googleapis.com \
bigquerydatatransfer.googleapis.com  cloudapis.googleapis.com cloudfunctions.googleapis.com \
elevation-backend.googleapis.com pubsub.googleapis.com run.googleapis.com storage-api.googleapis.com \
storage-component.googleapis.com storage.googleapis.com

gcloud iam service-accounts create terraform-service-acct --display-name="Terraform Service Account"
gcloud projects add-iam-policy-binding msd8654-434-bfro-dev --member='serviceAccount:terraform-service-acct@msd86
54-434-bfro-dev.iam.gserviceaccount.com' --role='roles/editor'

gcloud iam service-accounts keys create terraform-service-acct-key.json \
 --iam-account=terraform-service-acct@msd8654-434-bfro-dev.iam.gserviceaccount.com


