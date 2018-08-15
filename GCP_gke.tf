// Configure the Google Cloud provider
variable GCP_credentials {}
variable GCP_project {}
variable GCP_region {}
variable GKE_name {}
variable GKE_min_ver {}
variable GKE_zone {}
variable GKE_additional_zones { type = "list" }
variable GKE_master_auth {type = "list" }


provider "google" {
  credentials = "${ var.GCP_credentials }"
  project     = "${ var.GCP_project }"
  region      = "${ var.GCP_region }"
}

resource "google_container_cluster" "primary" {
  name               = "${ var.GKE_name }"
  zone               = "${ var.GKE_zone }"
  min_master_version = "${ var.GKE_min_ver }"
  network            = "${module.gcp-vpc.self_link}"
  subnetwork         = "${module.gcp-subnet1.self_link}"
  initial_node_count = 2

  additional_zones   = "${ var.GKE_additional_zones }"

  master_auth        = "${ var.GKE_master_auth }"

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels {
      foo = "bar"
    }

    tags = ["foo", "bar"]
  }
}

# The following outputs allow authentication and connectivity to the GKE Cluster.
output "client_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.client_certificate}"
}

output "client_key" {
  value = "${google_container_cluster.primary.master_auth.0.client_key}"
}

output "cluster_ca_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}"
}