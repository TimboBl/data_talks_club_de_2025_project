# Main Terraform configuration file for GCP resources

resource "google_bigquery_dataset" "eu_emissions_project" {
  dataset_id                  = "eu_emissions_project"
  friendly_name               = "EU Emissions Project"
  description                 = "Dataset for EU emissions data analysis"
  location                    = var.location
  project                     = var.project_id
  delete_contents_on_destroy  = var.delete_contents_on_destroy

  labels = {
    environment = var.environment
  }
}

# Google Cloud Storage bucket for the project
resource "google_storage_bucket" "eu_emissions_storage" {
  name          = "${var.project_id}-eu-emissions-${var.environment}"
  location      = var.location
  project       = var.project_id
  force_destroy = var.force_destroy_bucket
  storage_class = var.storage_class

  versioning {
    enabled = var.enable_versioning
  }

  labels = {
    environment = var.environment
  }
}
