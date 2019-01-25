// Common configurations for Istio
variable ISTIO_helm_yaml_url {}

variable ISTIO_chart_repo {}
variable ISTIO_chart_repo_name {}
variable ISTIO_version {}

locals {
  control_cluster_kubeconfig = "./kubeconfig_${google_container_cluster.primary.name}"
  remote_cluster_kubeconfig  = "./kubeconfig_${var.EKS_name}"
}

provider "helm" {
  #    alias  = "gke"
  service_account = "tiller"
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.11.0"

  kubernetes {
    config_path = "${ local.control_cluster_kubeconfig }"
  }
}

provider "helm" {
  alias           = "eks"
  service_account = "tiller"
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.11.0"

  kubernetes {
    config_path = "${ local.remote_cluster_kubeconfig }"
  }
}
