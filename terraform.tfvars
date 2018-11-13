##########################################################################################
# GCP Vars
# Project and Credentials must be configured via GCP Console
# https://console.cloud.google.com/projectcreate
# https://console.cloud.google.com/apis/credentials
# 
GCP_project                    = "k8s-hybrid-cloud"
GCP_credentials                = "/Users/braddown/.gcp/k8s-hybrid-cloud-0f1ceb09cf2a.json"
GCP_vpc_name                   = "hybrid-cloud"
GCP_region                     = "us-west1"
GCP_vpc_subnet                 = "172.17.0.0/17"
GCP_subnet_name                = "hybrid-cloud-a"
GKE_name                       = "gke-hybrid-cloud"
GKE_min_ver                    = "1.10"
GKE_cluster_ip                 = "172.17.128.0/17"
GKE_zone                       = "us-west1-a"
GKE_additional_zones           = ["us-west1-b", "us-west1-c"]
GKE_master_auth = [{
    username                   = "magic7s"
    password                   = "magic7s1234567890"
  }]

##########################################################################################
# AWS Vars
AWS_region                     = "us-west-2"
AWS_vpc_name                   = "hybrid-cloud"
AWS_vpc_subnet                 = "172.16.0.0/16"
AWS_azs                        = ["us-west-2a", "us-west-2b"]
AWS_public_subnets             = ["172.16.0.0/20", "172.16.16.0/20"]
EKS_name                       = "eks-hybrid-cloud"
EKS_worker_groups              = [
    { 
        "asg_desired_capacity" = "2",
        "key_name"             = "braddown-ciscolaptop"
    }]

##########################################################################################
# Istio Vars
ISTIO_crd_yaml_url              = "https://raw.githubusercontent.com/istio/istio/master/install/kubernetes/helm/istio/templates/crds.yaml"
ISTIO_helm_yaml_url             = "https://raw.githubusercontent.com/istio/istio/master/install/kubernetes/helm/helm-service-account.yaml"
ISTIO_chart_repo                = "https://s3-us-west-2.amazonaws.com/vxlan.io/charts"
ISTIO_chart_repo_name           = "istio"
ISTIO_version                   = "1.0.2"