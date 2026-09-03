output "ingress_class" {
  value = "traefik"
}

output "cluster_issuer" {
  value = "letsencrypt"
}

output "traefik_dashboard_url" {
  description = "Dashboard etkinse erişim adresi."
  value       = var.traefik_dashboard_enabled ? "https://${var.traefik_dashboard_domain}/dashboard/" : null
}
