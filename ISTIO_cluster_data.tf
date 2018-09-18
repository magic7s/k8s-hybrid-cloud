// Gather IP Info from Istio Cluster

data "external" "ISTO_CONTROL" {
  program = ["bash", "-c", "./get_istio_ips.py kubeconfig_${google_container_cluster.primary.name}"]
  depends_on = ["helm_release.istio-control-gke"]
}
