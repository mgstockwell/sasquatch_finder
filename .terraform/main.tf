terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.0.0"
    }
  }
}

provider "google" {
  # Configuration options
  project     = "msd8654-434-bfro-dev"
}

resource "google_storage_bucket" "static-site" {
  name          = "bfro_data"
  location      = "US"
  force_destroy = true

  uniform_bucket_level_access = true
}

resource "google_bigquery_dataset" "dataset" {
  dataset_id                  = "bfro"
  friendly_name               = "Bigfoot Research Org Data"
  description                 = "Bigfoot sightings with geolocation data"
  location                    = "US"
  default_table_expiration_ms = 3600000

  labels = {
    env = "default"
  }

}
