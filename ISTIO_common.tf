// Common configurations for Istio
variable ISTIO_crd_yaml_url {}
variable ISTIO_helm_yaml_url {}
variable ISTIO_chart_repo {}
variable ISTIO_chart_repo_name {}


provider "helm" {
#    alias  = "gke"
    service_account = "tiller"
    kubernetes {
        config_path = "./kubeconfig_${google_container_cluster.primary.name}"
    }
}

provider "helm" {
    alias  = "eks"
    service_account = "tiller"
    kubernetes {
        config_path = "./kubeconfig_${var.EKS_name}"
    }
}
