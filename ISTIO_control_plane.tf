// Install Istio control plane on gke cluster

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

resource "null_resource" "istio-helm-init" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_cert = "${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}"
  }

  provisioner "local-exec" {
    environment = { 
       KUBECONFIG = "./kubeconfig_${google_container_cluster.primary.name}"
       #HELM_HOME  = "./.helm-gcp/"
       }
    command = "helm init --service-account tiller; sleep 60"
  }
  provisioner "local-exec" {
    when    = "destroy"
    environment = { 
       KUBECONFIG = "./kubeconfig_${google_container_cluster.primary.name}"
       #HELM_HOME  = "./.helm-gcp/"
       }
    command = "helm reset --force --remove-helm-home"
  }
  depends_on = ["google_container_cluster.primary", "null_resource.istio-svc-act"]
}

resource "null_resource" "istio-helm-repo" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_cert = "${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}"
  }

  provisioner "local-exec" {
    environment = { 
       KUBECONFIG = "./kubeconfig_${google_container_cluster.primary.name}"
       #HELM_HOME  = "./.helm-gcp/"
       }
    command = "helm repo add ${var.ISTIO_chart_repo_name} ${var.ISTIO_chart_repo}"
  }
  provisioner "local-exec" {
    when    = "destroy"
    environment = { 
       KUBECONFIG = "./kubeconfig_${google_container_cluster.primary.name}"
       #HELM_HOME  = "./.helm-gcp/"
       }
    command = "helm repo remove ${var.ISTIO_chart_repo_name}"
  }
  depends_on = ["google_container_cluster.primary", "null_resource.istio-helm-init"]
}

resource "null_resource" "istio-helm-install" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_cert = "${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}"
  }

  provisioner "local-exec" {
    environment = { 
       KUBECONFIG = "./kubeconfig_${google_container_cluster.primary.name}"
       #HELM_HOME  = "./.helm-gcp/"
       }
    command = "helm install ${var.ISTIO_chart_repo_name}/istio --name istio --namespace istio-system"
  }
  provisioner "local-exec" {
    when    = "destroy"
    environment = { 
       KUBECONFIG = "./kubeconfig_${google_container_cluster.primary.name}"
       #HELM_HOME  = "./.helm-gcp/"
       }
    command = "helm delete --purge istio"
  }
  depends_on = ["google_container_cluster.primary", "null_resource.istio-helm-init", "null_resource.istio-helm-repo"]
}