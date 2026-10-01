locals {
  common_labels = {
    "app.kubernetes.io/managed-by" = "terraform"
    "talay.io/component"           = "network"
  }
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  namespace  = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.21.1"

  atomic  = true
  wait    = true
  timeout = 600

  values = [yamlencode({
    crds = { enabled = true }
    global = {
      priorityClassName = "talay-platform-critical"
      commonLabels      = local.common_labels
    }
    prometheus = {
      enabled        = true
      servicemonitor = { enabled = false }
    }
    podLabels = local.common_labels
  })]
}

resource "helm_release" "cluster_issuer" {
  name      = "talay-cluster-issuer"
  namespace = "cert-manager"
  chart     = var.cluster_issuer_chart_path

  atomic  = true
  wait    = true
  timeout = 300

  values = [yamlencode({
    email                = var.acme_email
    server               = var.letsencrypt_server
    privateKeySecretName = "letsencrypt-account-key"
    ingressClass         = "traefik"
  })]

  depends_on = [helm_release.cert_manager]
}
