terraform {
  required_providers {
    avi = {
      source  = "vmware/avi"
      version = "21.1.1"
    }
  }
}

locals {
  service_engine_group = "Default-Group"
  tenant_ref           = "/api/tenant/?name=admin"
  ipam-name            = "TCE-IPAM"
  avi-backup-config-name = "Backup-Configuration"
}

provider "avi" {
  avi_username   = var.avi-username
  avi_tenant     = var.avi-tenant
  avi_password   = var.avi-password
  avi_controller = data.terraform_remote_state.phase1.outputs.avi-controller-ip
  avi_version    = var.avi-version
}


data "terraform_remote_state" "phase1" {
  backend = "local"
  config = {
    path = "../phase1/terraform.tfstate"
  }
}

data "avi_sslkeyandcertificate" "default-ssl" {
  name = "System-Default-Cert"
}

data "avi_backupconfiguration" "backup-config" {
  name = local.avi-backup-config-name
}

resource "avi_network" "avi-mgmt" {
  name       = data.terraform_remote_state.phase1.outputs.avi-mgmt-network-name
  cloud_ref = avi_cloud.vcenter_cloud.id
  dhcp_enabled = false
  configured_subnets {
    prefix {
      mask = split("/",data.terraform_remote_state.phase1.outputs.avi-mgmt-network-cidr)[1]
      ip_addr {
        addr = cidrhost(data.terraform_remote_state.phase1.outputs.avi-mgmt-network-cidr, 0)
        type = "V4"
      }
    }
    static_ip_ranges  {
      range  {
        begin {
          addr = cidrhost(data.terraform_remote_state.phase1.outputs.avi-mgmt-network-cidr, 6)
          type = "V4"
        }
        end {
          addr = cidrhost(data.terraform_remote_state.phase1.outputs.avi-mgmt-network-cidr, 254)
          type = "V4"
        }
      }
      type = "STATIC_IPS_FOR_SE"
    }
  }
    depends_on = [avi_backupconfiguration.config,avi_systemconfiguration.system-config]
}

resource "avi_network" "tanzu-workloads-network" {
  name       = var.tanzu-workloads-network-name
  cloud_ref  = avi_cloud.vcenter_cloud.id
  configured_subnets {
    prefix {
      mask = split("/",var.tanzu-workloads-network-cidr)[1]
      ip_addr {
        addr = cidrhost(var.tanzu-workloads-network-cidr, 0)
        type = "V4"
      }
    }
      static_ip_ranges  {
        range  {
          begin {
            addr = cidrhost(var.tanzu-workloads-network-cidr, 5)
            type = "V4"
          }
          end {
            addr = cidrhost(var.tanzu-workloads-network-cidr, 45)
            type = "V4"
          }
        }
        type = "STATIC_IPS_FOR_VIP"
      }
  }
  depends_on = [avi_backupconfiguration.config,avi_systemconfiguration.system-config]
}

resource "avi_network" "tanzu-services-network" {
  name = var.tanzu-services-network-name
  cloud_ref = avi_cloud.vcenter_cloud.id
  configured_subnets {
    prefix {
      mask = split("/",var.tanzu-services-network-cidr)[1]
      ip_addr {
        addr = cidrhost(var.tanzu-services-network-cidr, 0)
        type = "V4"
      }
    }
    static_ip_ranges {
      range {
        begin {
          addr = cidrhost(var.tanzu-services-network-cidr, 5)
          type = "V4"
        }
        end {
          addr = cidrhost(var.tanzu-services-network-cidr, 45)
          type = "V4"
        }
      }
      type = "STATIC_IPS_FOR_VIP"
    }
  }
  depends_on = [
    avi_backupconfiguration.config,
    avi_systemconfiguration.system-config]
}

resource "avi_ipamdnsproviderprofile" "ipam-provider" {
  name = local.ipam-name
  type = "IPAMDNS_TYPE_INTERNAL"
  tenant_ref = local.tenant_ref
  internal_profile {
    usable_networks  {
      nw_ref = var.tanzu-services-network-name
    }
  }
  depends_on = [avi_backupconfiguration.config,avi_systemconfiguration.system-config]
}

resource "avi_systemconfiguration" "system-config" {
  uuid = "default"
  default_license_tier = "ESSENTIALS"
  email_configuration {
    smtp_type = "SMTP_LOCAL_HOST"
    auth_username = var.avi-username
    auth_password = var.avi-password
  }
  dns_configuration {
    search_domain = var.dns-search_domain
    server_list {
      addr = var.dns-server
      type = "V4"
    }

  }
  welcome_workflow_complete = false
}

resource "avi_backupconfiguration" "config" {
  name = local.avi-backup-config-name
  uuid = data.avi_backupconfiguration.backup-config.uuid
  backup_passphrase = var.avi-password
  save_local = true
}

resource "avi_cloud" "vcenter_cloud" {
  name = var.avi-cloud-name
  vtype = "CLOUD_VCENTER"
  dhcp_enabled = false
  ipam_provider_ref = avi_ipamdnsproviderprofile.ipam-provider.id
  se_group_template_ref = local.service_engine_group
  prefer_static_routes = true
  enable_vip_static_routes = true
  ip6_autocfg_enabled = false
  vcenter_configuration {
    vcenter_url        = data.terraform_remote_state.phase1.outputs.vsphere-server
    username           = data.terraform_remote_state.phase1.outputs.vsphere-user
    password           = data.terraform_remote_state.phase1.outputs.vsphere-password
    datacenter         = data.terraform_remote_state.phase1.outputs.vsphere-datacenter
    management_network = data.terraform_remote_state.phase1.outputs.avi-mgmt-network-name
    privilege          = "WRITE_ACCESS"

    management_ip_subnet {
      mask = split("/",data.terraform_remote_state.phase1.outputs.avi-mgmt-network-cidr)[1]
      ip_addr {
        addr = cidrhost(data.terraform_remote_state.phase1.outputs.avi-mgmt-network-cidr, 0)
        type = "V4"
      }
    }
  }
  depends_on = [avi_systemconfiguration.system-config]
}

//
//
resource "avi_vrfcontext" "global" {
  name = "global"
  cloud_ref = avi_cloud.vcenter_cloud.id
  system_default = true
  static_routes {
    route_id = 1
    next_hop {
      addr = cidrhost(var.tanzu-services-network-cidr, 1)
      type = "V4"
    }
    prefix {
      mask = 0
      ip_addr {
        addr = "0.0.0.0"#var.tanzu-services-network-cidr
        type = "V4"
      }
    }
  }
}

