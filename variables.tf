variable "kubeconfig_path" {
  type    = string
  default = "../talay-cluster/stacks/bootstrap/kubeconfig.yaml"
}

variable "acme_email" {
  description = "Let's Encrypt bildirim adresi."
  type        = string

  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.acme_email))
    error_message = "acme_email geçerli bir e-posta adresi olmalıdır."
  }
}

variable "letsencrypt_server" {
  type    = string
  default = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "traefik_dashboard_enabled" {
  description = "Traefik Dashboard'u TLS korumalı bir IngressRoute ile geçici olarak yayınlar."
  type        = bool
  default     = false
}

variable "traefik_dashboard_domain" {
  description = "Traefik Dashboard FQDN'i. Dashboard etkinken zorunludur."
  type        = string
  default     = null

  validation {
    condition = (
      !var.traefik_dashboard_enabled ||
      can(regex("^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?(?:\\.[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?)+$", coalesce(var.traefik_dashboard_domain, "")))
    )
    error_message = "traefik_dashboard_enabled true olduğunda geçerli bir traefik_dashboard_domain verilmelidir."
  }
}

variable "traefik_dashboard_dns_target" {
  description = "ExternalDNS'in dashboard kaydı için kullanacağı Traefik public IP'si veya hostname'i. Null ise DNS kaydı elle yönetilir."
  type        = string
  default     = null
}

variable "traefik_dashboard_allowed_cidrs" {
  description = "Dashboard erişimine izin verilen CIDR'ler. Boş liste geçici olarak herkese erişim verir."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for cidr in var.traefik_dashboard_allowed_cidrs : can(cidrhost(cidr, 0))])
    error_message = "traefik_dashboard_allowed_cidrs yalnızca geçerli IPv4/IPv6 CIDR değerleri içermelidir."
  }
}

variable "external_dns_enabled" {
  type    = bool
  default = false
}

variable "external_dns_provider" {
  description = "external-dns provider.name değeri (ör. cloudflare)."
  type        = string
  default     = "cloudflare"
}

variable "domain_filters" {
  type    = list(string)
  default = []
}

variable "external_dns_values" {
  description = "Kimlik bilgisi içermeyen, sağlayıcıya özgü ek ExternalDNS chart değerleri."
  type        = any
  default     = {}
}
