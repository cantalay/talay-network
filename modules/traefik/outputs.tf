output "ingress_class" { value = "traefik" }
output "dashboard_url" { value = var.dashboard_enabled ? "https://${var.dashboard_domain}/dashboard/" : null }
