variable "dashboard_enabled" { type = bool }
variable "dashboard_domain" { type = string }
variable "dashboard_dns_target" { type = string }
variable "dashboard_allowed_cidrs" { type = list(string) }
variable "dashboard_chart_path" { type = string }
