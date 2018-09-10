// Install Istio remote on EKS cluster

resource "null_resource" "istio-remote" {
  # Using count = 0 to disable this resource due to bug. https://github.com/istio/istio/issues/7688
  # Helm will install CRD, but docs say needs installed separate. Istio install will fail if installed twice.
  count = 0
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_cert = "${module.eks.cluster_certificate_authority_data}"
  }

  provisioner "local-exec" {
    environment = { KUBECONFIG = "./kubeconfig_${var.EKS_name}"}
    command = "kubectl apply -f ${var.ISTIO_crd_yaml_url}"
  }
  provisioner "local-exec" {
    when    = "destroy"
    environment = { KUBECONFIG = "./kubeconfig_${var.EKS_name}"}
    command = "kubectl delete -f ${var.ISTIO_crd_yaml_url}"
  }
  depends_on = ["module.eks"]
}

resource "null_resource" "istio-svc-act-remote" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_cert = "${module.eks.cluster_certificate_authority_data}"
  }

  provisioner "local-exec" {
    environment = { KUBECONFIG = "./kubeconfig_${var.EKS_name}"}
    command = "kubectl apply -f ${var.ISTIO_helm_yaml_url}"
  }
  provisioner "local-exec" {
    when    = "destroy"
    environment = { KUBECONFIG = "./kubeconfig_${var.EKS_name}"}
    command = "kubectl delete -f ${var.ISTIO_helm_yaml_url}"
  }
  depends_on = ["module.eks"]
}

resource "null_resource" "istio-helm-init-remote" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_cert = "${module.eks.cluster_certificate_authority_data}"
  }

  provisioner "local-exec" {
    environment = { 
       KUBECONFIG = "./kubeconfig_${var.EKS_name}"
       #HELM_HOME  = "./.helm-eks/"
       }
    command = "helm init --service-account tiller; sleep 120"
  }
  provisioner "local-exec" {
    when    = "destroy"
    environment = { 
       KUBECONFIG = "./kubeconfig_${var.EKS_name}"
       #HELM_HOME  = "./.helm-eks/"
       }
    command = "helm reset --force"
  }
  depends_on = ["module.eks", "null_resource.istio-svc-act-remote"]
}

resource "null_resource" "istio-helm-repo-remote" {
  # Using count = 0 to disable this resource due to bug. The repo is already added with the control cluster.
  count = 0
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_cert = "${module.eks.cluster_certificate_authority_data}"
  }

  provisioner "local-exec" {
    environment = { 
       KUBECONFIG = "./kubeconfig_${var.EKS_name}"
       #HELM_HOME  = "./.helm-eks/"
       }
    command = "helm repo add ${var.ISTIO_chart_repo_name} ${var.ISTIO_chart_repo}"
  }
  provisioner "local-exec" {
    when    = "destroy"
    environment = { 
       KUBECONFIG = "./kubeconfig_${var.EKS_name}"
       #HELM_HOME  = "./.helm-eks/"
       }
    command = "helm repo remove ${var.ISTIO_chart_repo_name}"
  }
  depends_on = ["module.eks", "null_resource.istio-helm-init-remote"]
}

resource "null_resource" "istio-helm-install-remote" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_cert = "${module.eks.cluster_certificate_authority_data}"
  }

  provisioner "local-exec" {
    environment = { 
       KUBECONFIG = "./kubeconfig_${var.EKS_name}"
       #HELM_HOME  = "./.helm-eks/"
       }
    command = "helm install ${var.ISTIO_chart_repo_name}/istio-remote --name istio-remote --namespace istio-system --set global.remotePilotAddress=${data.external.ISTO_CONTROL.result.PILOT_POD_IP} --set global.remotePolicyAddress=${data.external.ISTO_CONTROL.result.POLICY_POD_IP} --set global.remoteTelemetryAddress=${data.external.ISTO_CONTROL.result.TELEMETRY_POD_IP} --set global.proxy.envoyStatsd.enabled=true --set global.proxy.envoyStatsd.host=${data.external.ISTO_CONTROL.result.STATSD_POD_IP} --set global.remoteZipkinAddress=${data.external.ISTO_CONTROL.result.ZIPKIN_POD_IP}; sleep 120"
  }
  provisioner "local-exec" {
    when    = "destroy"
    environment = { 
       KUBECONFIG = "./kubeconfig_${var.EKS_name}"
       #HELM_HOME  = "./.helm-eks/"
       }
    command = "helm delete --purge istio-remote"
  }
  depends_on = ["null_resource.istio-helm-install", "module.eks", "null_resource.istio-helm-init-remote", "null_resource.istio-helm-repo-remote"]
}
