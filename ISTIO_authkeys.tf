// After Istio is installed. Install service accounts.

resource "null_resource" "istio-istio-remote-script" {
  triggers = {
    cluster_instance_cert_primary = "${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}"
    cluster_instance_cert_remote  = "${module.eks.cluster_certificate_authority_data}"
  }
  provisioner "local-exec" {
    command = "./put_istio_remote_auth.sh ${ local.remote_cluster_kubeconfig } ${var.EKS_name} ${ local.control_cluster_kubeconfig }"
  }
  provisioner "local-exec" {
    when    = "destroy"
    command = "rm ./remote-cluster-auth"
  }  
  depends_on = ["helm_release.istio-remote-eks", "helm_release.istio-control-gke"]
}

