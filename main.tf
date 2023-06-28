locals {
  dns_flat_list = {
    for dns in var.dns_list : dns => {
      dns = dns
      i = index(var.dns_list, dns) + 1
    }
  }
}

# Generate random zone for each node
resource "random_string" "random_postfix" {
  length    = var.random_postfix_length
  lower     = true
  upper     = false
  special   = false
}

resource "google_certificate_manager_dns_authorization" "wildcard_cert_dns_auth" {
  for_each    = local.dns_flat_list
  name        = "dns-auth${each.value.i}-${random_string.random_postfix.result}"
  domain      = replace(each.value.dns, "*.", "")
}
resource "google_certificate_manager_certificate" "wildcard_cert" {
  name        = "wildcard-cert-${random_string.random_postfix.result}"
  scope       = "DEFAULT"
  managed {
    domains = concat([
      for domain in google_certificate_manager_dns_authorization.wildcard_cert_dns_auth : domain.domain
    ], [
      for domain in google_certificate_manager_dns_authorization.wildcard_cert_dns_auth : "*.${domain.domain}"
    ])
    dns_authorizations = [ for domain in google_certificate_manager_dns_authorization.wildcard_cert_dns_auth : domain.id ]
  }
}
resource "google_certificate_manager_certificate_map" "wildcard_cert_map" {
  name = "wildcard-cert-map-${random_string.random_postfix.result}"
}
resource "google_certificate_manager_certificate_map_entry" "wildcard_cert_map_entry" {
  for_each     = local.dns_flat_list
  name         = "wildcard-cert-map-entry${each.value.i}-${random_string.random_postfix.result}"
  map          = google_certificate_manager_certificate_map.wildcard_cert_map.name
  certificates = [ google_certificate_manager_certificate.wildcard_cert.id ]
  hostname     = each.value.dns
}
