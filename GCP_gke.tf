// Configure the Google Cloud provider


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
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${ var.GKE_name }"
    environment = { KUBECONFIG = "./kubeconfig_${var.GKE_name}"}
  }
  provisioner "local-exec" {
    when    = "destroy"
    command = "rm -f ./kubeconfig_${var.GKE_name}"
  }
}


