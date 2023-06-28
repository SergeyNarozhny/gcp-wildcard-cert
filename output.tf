output "cert" {
    value = google_certificate_manager_certificate.wildcard_cert
}
output "cert_map" {
    value = google_certificate_manager_certificate_map.wildcard_cert_map
}
output "dns_resource_records" {
    value = values(google_certificate_manager_dns_authorization.wildcard_cert_dns_auth)[*].dns_resource_record
}
