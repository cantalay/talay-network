locals {
  common_labels = {
    "app.kubernetes.io/managed-by" = "terraform"
    "talay.io/component"           = "network"
  }
}

resource "helm_release" "traefik" {
  name       = "traefik"
  namespace  = "ingress-system"
  repository = "https://traefik.github.io/charts"
  chart      = "traefik"
  version    = "41.4.0"

  atomic  = true
  wait    = true
  timeout = 600

  values = [yamlencode({
    api = { dashboard = true, insecure = false }
    deployment = {
      replicas  = 1
      podLabels = local.common_labels
    }
    priorityClassName = "talay-platform-critical"
    ingressClass = {
      enabled        = true
      isDefaultClass = true
      name           = "traefik"
    }
    providers = {
      kubernetesCRD = { enabled = true }
      kubernetesIngress = {
        enabled          = true
        publishedService = { enabled = true }
      }
    }
    ports = {
      web = {
        http = {
          redirections = {
            entryPoint = { to = "websecure", scheme = "https", permanent = true }
          }
        }
      }
      websecure = { http = { tls = { enabled = true } } }
    }
    service = { spec = { externalTrafficPolicy = "Local" } }
    metrics = {
      prometheus = {
        service = {
          enabled = true
          annotations = {
            "prometheus.io/scrape" = "true"
            "prometheus.io/port"   = "9100"
          }
        }
        serviceMonitor = { enabled = false }
      }
    }
  })]
}

resource "helm_release" "traefik_dashboard" {
  count = var.dashboard_enabled ? 1 : 0

  name      = "traefik-dashboard"
  namespace = "ingress-system"
  chart     = var.dashboard_chart_path

  atomic  = true
  wait    = true
  timeout = 300

  values = [yamlencode({
    domain        = var.dashboard_domain
    dnsTarget     = var.dashboard_dns_target
    tlsSecretName = "traefik-dashboard-tls"
    allowedCIDRs  = var.dashboard_allowed_cidrs
  })]

  depends_on = [helm_release.traefik]
}
