# talay-network

Cluster girişini ve DNS/TLS otomasyonunu yönetir:

- Traefik ingress controller (`41.4.0`)
- cert-manager ve CRD'leri (`v1.21.1`)
- ACME ClusterIssuer
- İsteğe bağlı ExternalDNS (`1.21.1`)
- Feature flag ile açılan Traefik Dashboard (`/dashboard/`)

ExternalDNS varsayılan olarak kapalıdır; DNS sağlayıcısının kimlik bilgileri Terraform'a verilmemeli, önceden Vault/ExternalSecret ile oluşturulmuş bir Secret veya workload identity kullanılmalıdır. `external_dns_values` sağlayıcıya özel chart değerlerini taşır.

## Geçici Traefik Dashboard

`traefik_dashboard_enabled = true` olduğunda dashboard yalnızca `websecure` üzerinden yayınlanır ve `api.insecure` kapalı kalır. TLS sertifikasını cert-manager, `letsencrypt` ClusterIssuer ile üretir. Adres `https://<traefik_dashboard_domain>/dashboard/` biçimindedir; sondaki `/` gereklidir.

Keycloak veya başka bir oturum açma katmanı eklenmemiştir. `traefik_dashboard_allowed_cidrs = []` dashboard'u internete açık bırakır. Mümkünse yönetici IP aralıklarını bu listeye yazın ve inceleme tamamlandığında `traefik_dashboard_enabled = false` yapın.

ExternalDNS etkinse Traefik `IngressRoute` kaynakları da izlenir. Otomatik DNS kaydı için `traefik_dashboard_dns_target` alanına Traefik'in public IP'sini veya hostname'ini verin; null bırakılırsa A/AAAA/CNAME kaydını DNS sağlayıcısında elle oluşturun.
