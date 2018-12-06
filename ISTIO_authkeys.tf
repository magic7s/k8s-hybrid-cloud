// After Istio is installed. Install service accounts.

resource "null_resource" "istio-istio-remote-script" {

  provisioner "local-exec" {
    command = "./put_istio_remote_auth.sh ${ local.remote_cluster_kubeconfig } ${var.EKS_name} ${ local.control_cluster_kubeconfig }"
  }
  
  depends_on = ["helm_release.istio-remote-eks", "helm_release.istio-control-gke"]
}

