// Install Helm on both clusters

resource "null_resource" "istio-svc-act-gke" {
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

resource "null_resource" "istio-svc-act-eks" {
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

resource "helm_repository" "istio" {
    name = "${var.ISTIO_chart_repo_name}"
    url  = "${var.ISTIO_chart_repo}"
}

resource "helm_release" "istio-control-gke" {
  #provider = "helm.gke"
  repository = "${var.ISTIO_chart_repo_name}"
  name = "istio"
  chart = "istio"
  namespace = "istio-system"
  set {
    name = "grafana.enabled"
    value = "true"
  }
  depends_on = ["null_resource.istio-svc-act-gke"]
}

resource "helm_release" "istio-remote-eks" {
  provider = "helm.eks"
  repository = "${var.ISTIO_chart_repo_name}"
  name = "istio-remote"
  chart = "istio-remote"
  namespace = "istio-system"
  set {
    name = "grafana.enabled"
    value = "true"
  }
  set {
    name = "global.remotePilotAddress"
    value = "${lookup(data.external.ISTO_CONTROL.result, "PILOT_POD_IP")}"
  }
  set {
    name = "global.remotePolicyAddress"
    value = "${lookup(data.external.ISTO_CONTROL.result, "POLICY_POD_IP")}"
  }
  set {
    name = "global.remoteTelemetryAddress"
	value = "${lookup(data.external.ISTO_CONTROL.result, "TELEMETRY_POD_IP")}"
  }
  set {
    name = "global.proxy.envoyStatsd.enabled"
    value = "true"
  }
  set {
    name = "global.proxy.envoyStatsd.host"
    value = "${lookup(data.external.ISTO_CONTROL.result, "STATSD_POD_IP")}"
  }
  set {
    name = "global.remoteZipkinAddress"
    value = "${lookup(data.external.ISTO_CONTROL.result, "ZIPKIN_POD_IP")}"
  }
  depends_on = ["null_resource.istio-svc-act-eks", "helm_release.istio-control-gke", "data.external.ISTO_CONTROL"]
}