output "ingress_class" {
  value = module.traefik.ingress_class
}

output "cluster_issuer" {
  value = module.cert_manager.cluster_issuer
}

output "traefik_dashboard_url" {
  description = "Dashboard etkinse erişim adresi."
  value       = module.traefik.dashboard_url
}
