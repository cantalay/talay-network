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
    api = {
      dashboard = true
      insecure  = false
    }
    deployment = {
      replicas = 1
    }
    priorityClassName = "talay-platform-critical"
    ingressClass = {
      enabled        = true
      isDefaultClass = true
      name           = "traefik"
    }
    providers = {
      kubernetesCRD = {
        enabled = true
      }
      kubernetesIngress = {
        enabled = true
        publishedService = {
          enabled = true
        }
      }
    }
    ports = {
      web = {
        http = {
          redirections = {
            entryPoint = {
              to        = "websecure"
              scheme    = "https"
              permanent = true
            }
          }
        }
      }
      websecure = {
        http = {
          tls = {
            enabled = true
          }
        }
      }
    }
    service = {
      spec = {
        externalTrafficPolicy = "Local"
      }
    }
    metrics = {
      prometheus = {
        service = {
          enabled = true
          annotations = {
            "prometheus.io/scrape" = "true"
            "prometheus.io/port"   = "9100"
          }
        }
        serviceMonitor = {
          enabled = false
        }
      }
    }
    podLabels = local.common_labels
  })]
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
    crds = {
      enabled = true
    }
    global = {
      priorityClassName = "talay-platform-critical"
      commonLabels      = local.common_labels
    }
    prometheus = {
      enabled = true
      servicemonitor = {
        enabled = false
      }
    }
    podLabels = local.common_labels
  })]
}

resource "helm_release" "cluster_issuer" {
  name      = "talay-cluster-issuer"
  namespace = "cert-manager"
  chart     = "${path.module}/charts/cluster-issuer"

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

resource "helm_release" "external_dns" {
  count = var.external_dns_enabled ? 1 : 0

  name       = "external-dns"
  namespace  = "ingress-system"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = "1.21.1"

  atomic  = true
  wait    = true
  timeout = 600

  values = [yamlencode(merge({
    provider = {
      name = var.external_dns_provider
    }
    domainFilters = var.domain_filters
    policy        = "sync"
    registry      = "txt"
    txtOwnerId    = "talay-platform"
    sources       = ["ingress", "service", "traefik-proxy"]
    serviceMonitor = {
      enabled = false
    }
    service = {
      annotations = {
        "prometheus.io/scrape" = "true"
        "prometheus.io/port"   = "7979"
      }
    }
    priorityClassName = "talay-platform-critical"
  }, var.external_dns_values))]
}

resource "helm_release" "traefik_dashboard" {
  count = var.traefik_dashboard_enabled ? 1 : 0

  name      = "traefik-dashboard"
  namespace = "ingress-system"
  chart     = "${path.module}/charts/traefik-dashboard"

  atomic  = true
  wait    = true
  timeout = 300

  values = [yamlencode({
    domain        = var.traefik_dashboard_domain
    dnsTarget     = var.traefik_dashboard_dns_target
    tlsSecretName = "traefik-dashboard-tls"
    allowedCIDRs  = var.traefik_dashboard_allowed_cidrs
  })]

  depends_on = [
    helm_release.traefik,
    helm_release.cluster_issuer,
  ]
}
