// Install Istio control plane on one cluster

resource "null_resource" "istio-control" {
  # Using count = 0 to disable this resource due to bug. https://github.com/istio/istio/issues/7688
  # Helm will install CRD, but docs say needs installed separate. Istio install will fail if installed twice.
  count = 0
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_cert = "${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}"
  }

  provisioner "local-exec" {
    environment = { KUBECONFIG = "./kubeconfig_${google_container_cluster.primary.name}"}
    command = "kubectl apply -f ${var.ISTIO_crd_yaml_url}"
  }
  provisioner "local-exec" {
    when    = "destroy"
    environment = { KUBECONFIG = "./kubeconfig_${google_container_cluster.primary.name}"}
    command = "kubectl delete -f ${var.ISTIO_crd_yaml_url}"
  }
  depends_on = ["google_container_cluster.primary"]
}

resource "null_resource" "istio-svc-act" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_cert = "${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}"
  }

  provisioner "local-exec" {
    environment = { KUBECONFIG = "./kubeconfig_${google_container_cluster.primary.name}"}
    command = "kubectl apply -f ${var.ISTIO_helm_yaml_url}"
  }
  provisioner "local-exec" {
    when    = "destroy"
    environment = { KUBECONFIG = "./kubeconfig_${google_container_cluster.primary.name}"}
    command = "kubectl delete -f ${var.ISTIO_helm_yaml_url}"
  }
  depends_on = ["google_container_cluster.primary"]
}

resource "null_resource" "istio-helm-install" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_cert = "${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}"
  }

  provisioner "local-exec" {
    environment = { 
       KUBECONFIG = "./kubeconfig_${google_container_cluster.primary.name}"
       HELM_HOME  = "~/.helm/"
       }
    command = "helm init --service-account tiller; helm repo add vxlan.io ${ISTIO_chart_repo}; helm install vxlan.io/istio --name istio --namespace istio-system"
  }
  provisioner "local-exec" {
    when    = "destroy"
    environment = { 
       KUBECONFIG = "./kubeconfig_${google_container_cluster.primary.name}"
       HELM_HOME  = "~/.helm/"
       }
    command = "helm reset --force"
  }
  depends_on = ["google_container_cluster.primary"]
}