module "cert_manager" {
  source = "./modules/cert-manager"

  acme_email                = var.acme_email
  letsencrypt_server        = var.letsencrypt_server
  cluster_issuer_chart_path = "${path.root}/charts/cluster-issuer"
}

module "traefik" {
  source = "./modules/traefik"

  dashboard_enabled       = var.traefik_dashboard_enabled
  dashboard_domain        = var.traefik_dashboard_domain
  dashboard_dns_target    = var.traefik_dashboard_dns_target
  dashboard_allowed_cidrs = var.traefik_dashboard_allowed_cidrs
  dashboard_chart_path    = "${path.root}/charts/traefik-dashboard"
}

module "external_dns" {
  source = "./modules/external-dns"

  enabled        = var.external_dns_enabled
  provider_name  = var.external_dns_provider
  domain_filters = var.domain_filters
  values         = var.external_dns_values
}

moved {
  from = helm_release.traefik
  to   = module.traefik.helm_release.traefik
}

moved {
  from = helm_release.traefik_dashboard
  to   = module.traefik.helm_release.traefik_dashboard
}

moved {
  from = helm_release.cert_manager
  to   = module.cert_manager.helm_release.cert_manager
}

moved {
  from = helm_release.cluster_issuer
  to   = module.cert_manager.helm_release.cluster_issuer
}

moved {
  from = helm_release.external_dns
  to   = module.external_dns.helm_release.external_dns
}
