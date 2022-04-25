

output "avi-username" {
  value     = var.avi-username
  sensitive = true
}

output "avi-password" {
  value     = var.avi-password
  sensitive = true
}

output "avi-data-network-name" {
  value = avi_network.tanzu-services-network
}

//output "avi-data-network-cidr" {
//  value =
//}

output "avi-tenant-ref" {
  value = local.tenant_ref
}

output "avi-cloud" {
  value = avi_cloud.HomeLab.name
}

output "avi-se-group" {
  value = local.service_engine_group
}

output "tanzu-services-network-cidr" {
  value = var.tanzu-services-network-cidr
}

output "tanzu-services-network-name" {
  value = var.tanzu-services-network-name
}

output "tanzu-workloads-network-cidr" {
  value = var.tanzu-workloads-network-cidr
}

output "tanzu-workloads-network-name" {
  value = var.tanzu-workloads-network-name
}

output "cert" {
  value = data.avi_sslkeyandcertificate.default-ssl
}