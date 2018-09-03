// Common configurations for GCP

variable GCP_credentials {}
variable GCP_project {}
variable GCP_region {}
variable GKE_name {}
variable GKE_min_ver {}
variable GKE_zone {}
variable GKE_additional_zones { type = "list" }
variable GKE_master_auth {type = "list" }
variable GCP_vpc_name {}
variable GCP_subnet_name {}
variable GCP_vpc_subnet {}


provider "google" {
  credentials = "${ var.GCP_credentials }"
  project     = "${ var.GCP_project }"
  region      = "${ var.GCP_region }"
} 
