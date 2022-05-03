variable "vm_folder" {
  type    = string
}

variable "tanzu-cli" {
  description = "The path to your Tanzu CLI file (.tar.gz)"
  type = string
}

variable "kubectl_version" {
  description = "The version of kubectl to install in the Jumpbox"
  type = string
}


variable "ssh_key-pub-file" {
  default = null
}

variable "ssh_key-file" {
  default = null
}

variable "ssh_key-pub" {

}

variable "ssh_key" {

}

//variable "kubectl-vmware-cli" {
//  description = "The VMware's official kubectl cli (not required for TCE)"
//  default = ""
//  type = string
//}



