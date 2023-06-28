# Wildcard SSL Cert
Creates all required entities for GCP wildcard SSL cert:
- Certificate manager,
- DNS authorization requests,
- Certificate map + entries.

## Params
- dns_list - доменные имена для wildcard-сертов: массив значений, например, ["*.cabinettest.com"]

## Usage example
### Example 1 - https frontend, https backend
```
module "wildcard_cert" {
  source = "git@gitlab.fbs-d.com:terraform/modules/wildcard-cert.git"
  dns_list = ["*.cabinettest.com"]
}
```

## DNS
Для корректного выпуска сертификатов по схеме DNS-record авторизации, необходимо создать соответствующие записи (CNAME) на стороне CloudFlare или GCP. Значения записей доступны в output модуля `wildcard_cert.dns_resource_records`. Пример для создания записей на CF через terraform:
```
resource "cloudflare_record" "domain_dns_confirmation_records" {
  for_each = {
    for rec in flatten(module.wildcard_cert.dns_resource_records) : rec.data => rec
  }
  zone_id  = data.cloudflare_zone.cabinettestcom_zone.id
  name     = each.value.name
  value    = each.value.data
  type     = each.value.type
  proxied  = false
}
```

## Outputs
```
- wildcard_cert.cert
- wildcard_cert.cert_map
- wildcard_cert.dns_resource_records
```
