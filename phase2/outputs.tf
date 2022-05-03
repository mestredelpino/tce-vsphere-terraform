

output "avi-username" {
  value     = var.avi_controller_username
  sensitive = true
}

output "avi-password" {
  value     = var.avi_controller_password
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
  value = avi_cloud.vcenter_cloud.name
}

output "avi-se-group" {
  value = local.service_engine_group
}

output "tanzu-services-network-cidr" {
  value = var.tanzu_services_network_cidr
}

output "tanzu-services-network-name" {
  value = var.tanzu_services_network_name
}

output "tanzu-workloads-network-cidr" {
  value = var.tanzu_workloads_network_cidr
}

output "tanzu-workloads-network-name" {
  value = var.tanzu_workloads_network_name
}

output "cert" {
  value = data.avi_sslkeyandcertificate.default-ssl
}

