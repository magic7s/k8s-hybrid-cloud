// Install Istio via Helm and Tiller on both clusters

resource "null_resource" "istio-svc-act-gke" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_cert = "${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}"
  }

  provisioner "local-exec" {
    environment = {
      KUBECONFIG = "${ local.control_cluster_kubeconfig }"
    }

    command = "sleep 60;kubectl apply -f ${var.ISTIO_helm_yaml_url}"
  }

  provisioner "local-exec" {
    when = "destroy"

    environment = {
      KUBECONFIG = "${ local.control_cluster_kubeconfig }"
    }

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
    environment = {
      KUBECONFIG = "${ local.remote_cluster_kubeconfig }"
    }

    command = "sleep 60;kubectl apply -f ${var.ISTIO_helm_yaml_url}"
  }

  provisioner "local-exec" {
    when = "destroy"

    environment = {
      KUBECONFIG = "${ local.remote_cluster_kubeconfig }"
    }

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
  name       = "istio"
  chart      = "istio"
  version    = "${var.ISTIO_version}"
  namespace  = "istio-system"

  values = [<<EOF
grafana.enabled : true
kiali.enabled : true
tracing.enabled : true
servicegraph.enabled : true
EOF
  ]

  depends_on = ["null_resource.istio-svc-act-gke", "helm_repository.istio"]
}

// Gather IP Info from Istio Cluster
data "external" "ISTO_CONTROL" {
  program    = ["bash", "-c", "./get_istio_ips.py ${ local.control_cluster_kubeconfig }"]
  depends_on = ["helm_release.istio-control-gke"]
}

resource "helm_release" "istio-remote-eks" {
  provider   = "helm.eks"
  repository = "${var.ISTIO_chart_repo_name}"
  name       = "istio-remote"
  chart      = "istio-remote"
  version    = "${var.ISTIO_version}"
  namespace  = "istio-system"

  values = [<<EOF
global.remotePilotAddress : "${lookup(data.external.ISTO_CONTROL.result, "PILOT_POD_IP")}"
global.remotePolicyAddress : "${lookup(data.external.ISTO_CONTROL.result, "POLICY_POD_IP")}"
global.remoteTelemetryAddress : "${lookup(data.external.ISTO_CONTROL.result, "TELEMETRY_POD_IP")}"
global.proxy.envoyStatsd.enabled : true
global.proxy.envoyStatsd.host : "${lookup(data.external.ISTO_CONTROL.result, "STATSD_POD_IP")}"
global.remoteZipkinAddress : "${lookup(data.external.ISTO_CONTROL.result, "ZIPKIN_POD_IP")}"
EOF
  ]

  depends_on = ["module.eks", "null_resource.istio-svc-act-eks", "helm_release.istio-control-gke", "data.external.ISTO_CONTROL", "helm_repository.istio"]
}

// Label namespace with istio automatic injection
resource "null_resource" "istio-namespace-label-gke" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_cert = "${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}"
  }

  provisioner "local-exec" {
    environment = {
      KUBECONFIG = "${ local.control_cluster_kubeconfig }"
    }

    command = "kubectl label namespace default istio-injection=enabled"
  }

  provisioner "local-exec" {
    when = "destroy"

    environment = {
      KUBECONFIG = "${ local.control_cluster_kubeconfig }"
    }

    command = "kubectl label namespace default istio-injection-"
  }

  depends_on = ["helm_release.istio-control-gke"]
}

// Label namespace with istio automatic injection
resource "null_resource" "istio-namespace-label-eks" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_cert = "${module.eks.cluster_certificate_authority_data}"
  }

  provisioner "local-exec" {
    environment = {
      KUBECONFIG = "${ local.remote_cluster_kubeconfig }"
    }

    command = "kubectl label namespace default istio-injection=enabled"
  }

  provisioner "local-exec" {
    when = "destroy"

    environment = {
      KUBECONFIG = "${ local.remote_cluster_kubeconfig }"
    }

    command = "kubectl label namespace default istio-injection-"
  }

  depends_on = ["helm_release.istio-remote-eks"]
}
