resource "helm_release" "external_dns" {
  count = var.enabled ? 1 : 0

  name       = "external-dns"
  namespace  = "ingress-system"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = "1.21.1"

  atomic  = true
  wait    = true
  timeout = 600

  values = [yamlencode(merge({
    provider       = { name = var.provider_name }
    domainFilters  = var.domain_filters
    policy         = "sync"
    registry       = "txt"
    txtOwnerId     = "talay-platform"
    sources        = ["ingress", "service", "traefik-proxy"]
    serviceMonitor = { enabled = false }
    service = {
      annotations = {
        "prometheus.io/scrape" = "true"
        "prometheus.io/port"   = "7979"
      }
    }
    priorityClassName = "talay-platform-critical"
  }, var.values))]
}
