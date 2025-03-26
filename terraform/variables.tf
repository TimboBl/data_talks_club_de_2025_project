# Variables for GCP BigQuery dataset configuration

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "location" {
  description = "The location for the BigQuery dataset"
  type        = string
  default     = "EU"
}

variable "environment" {
  description = "Environment label for resources"
  type        = string
  default     = "dev"
}

variable "delete_contents_on_destroy" {
  description = "Whether to delete the contents when the dataset is destroyed"
  type        = bool
  default     = false
}

# Storage bucket variables
variable "force_destroy_bucket" {
  description = "When deleting a bucket, this boolean option will delete all contained objects"
  type        = bool
  default     = false
}

variable "storage_class" {
  description = "The Storage Class of the bucket"
  type        = string
  default     = "STANDARD"
}

variable "enable_versioning" {
  description = "Whether to enable versioning for the bucket"
  type        = bool
  default     = false
}
