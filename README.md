## TCE with NSX ALB on vSphere with Terraform

Deploy Tanzu Kubernetes Grid (Tanzu Community Edition) with an NSX Advanced Load Balancer (or AVI) with Terraform

### Setting up the environment

1. [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
2. [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-windows.html) and [add it to path](https://docs.aws.amazon.com/cli/latest/userguide/install-windows.html#awscli-install-windows-path)
3. [Install PowerCLI](https://docs.vmware.com/en/VMware-vSphere/7.0/com.vmware.esxi.install.doc/GUID-F02D0C2D-B226-4908-9E5C-2E783D41FE2D.html)
4. [Install OpenSSH Client and Server](https://www.thomasmaurer.ch/2020/04/enable-powershell-ssh-remoting-in-powershell-7/)
5. Generate an ssh key by running `ssh-keygen -t rsa -b 2048`
6. Install [OVF tool](https://www.vmware.com/support/developer/ovf/) (might be needed for troubleshooting)


### Downloading the necessary files

1. Download the [ubuntu server cloud image OVA](https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.ova)
   (used for the jumpbox VM) and paste it in /SDDC-Deployment/vmware/ovas
2. Open your browser and navigate to the [download page of the tanzu OVA files](https://my.vmware.com/en/group/vmware/downloads/info/slug/infrastructure_operations_management/vmware_tanzu_kubernetes_grid/1_x)
3. Clone this repo to your desired location
4. Download the [**Tanzu OVA (ubuntu or photon)**](https://customerconnect.vmware.com/downloads/get-download?downloadGroup=TCE-090). Store it in your machine and save the path for later.
5. Download the [**VMWare TCE CLI for Linux**](https://tanzucommunityedition.io/download/). Store it in your machine and save the path for later.

## 1. Deploying the VM templates and an NSX ALB controller

1. Create a file phase1/terraform.tfvars

```
vsphere_user               = "" # Your vSphere user
vsphere_password           = "" # Your vSphere password
vsphere_server             = "" # Your vCenter server
vsphere_datacenter         = "" # Your vCenter datacenter
vsphere_host               = "" # The vSphere host where the VMs will get deployed into
vsphere_datastore          = "" # A VSphere datastore accessible from your vSphere host
vsphere_resource_pool      = "" # The resource pool for the VM deployment (optional)
vsphere_network            = "" # The network in which to allocate the VMs

vsphere_vm_folder          = "" # The vSphere folder 

# NSX ALB template VM
avi_controller_ip          = "" # The IP address for the AVI controller to deploy
avi_mgmt_network_cidr      = "" # The network CIDR of for the AVI management network
avi_mgmt_network_name      = "" # The name of the AVI management network
avi_mgmt_network_gw        = "" # The IP address of the AVI management network's gateway
avi_vm_name                = "" # The name for the AVI controller VM (default "avi-controller")
remote_ova_url_avi         = "" # The remote url to the AVI OVA (set only one of remote or local)
local_ova_path_avi         = "" # The remote url to the AVI OVA (set only one of remote or local)

vsphere_vm_template_folder = "" # The folder to contain the ubuntu and Tanzu template VMs

# Ubuntu template VM
focal_ova_name             = "" # The name for the ubuntu template VM (used as an image for the jumpbox)

# Tanzu template VM
tanzu_ova_name             = "" # The name for the Tanzu template VM
remote_ova_url_tanzu       = "" # The remote url to the Tanzu OVA (set only one of remote or local)
local_ova_path_tanzu       = "" # The local path to the Tanzu OVA (set only one of remote or local)
```

2. Open up a console
2. Navigate to the *"phase1"* directory
3. Run `terraform init`
4. Run `terraform apply`

### Turning the Tanzu VM into a template
For Kubernetes to be deployed, it needs a valid template of the OVA filr you just use to create a VM with.
You can turn this VM into a template by running this:

```
Set-PowerCLIConfiguration -InvalidCertificateAction:Ignore -Confirm:$false
Connect-VIServer -Server <vCenter address> -User <vCenter user> -Password <vCenter Password>
Stop-VM -VM <Tanzu template VM> -Confirm:$false
Get-VM -Name <Tanzu template VM> | Set-VM -ToTemplate -Confirm:$false
```

## 2. Configuring the NSX ALB Controller

### Setting up a password + passphrase

A few minutes after the NSX ALB controller VM has been deployed, you can access it with
your browser. Once there, write a passphrase, which will be used by backup configurations.

This process can be automated as William Lam explains in [this blogpost](https://williamlam.com/2021/03/automating-default-admin-password-change-for-nsx-advanced-load-balancer-nsx-alb.html).

### Configuring NSX ALB for Tanzu

1. Create a file phase2/terraform.tfvars

```
avi_controller_username      = "" # The NSX ALB username 
avi_controller_password      = "" # The NSX ALB password
avi_tenant                   = "" # THe NSX ALB tennant
avi_version                  = "" # The version of the NSX ALB controller
avi_cloud_name               = "" # The NSX ALB cloud to create

dns_server                   = "" # Your DNS server
dns_search_domain            = "" # Your DNS search domain
dns_server_list              = "" # Your DNS server address

tanzu_services_network-cidr  = "" # The network cidr of the Tanzu services (VIP)
tanzu_services_network-name  = "" # The name of the Tanzu services network
tanzu_workloads_network-cidr = "" # The network cidr of the Tanzu workloads (nodes)
tanzu_workloads_network-name = "" # The name of the Tanzu workloads network

```
2. Navigate to the *"phase2"* directory
3. Run `terraform init`
4. Run `terraform apply`

## 3. Deploying the Tanzu jumpbox

1. Create a file phase3/terraform.tfvars
2. Navigate to the *"phase3"* directory

```
tanzu_cli        = "" # The file containing the Tanzu CLI
vm_folder        = "" # The folder (to create) that will contain the cluster node VMs
kubectl_version  = "" # The kubernetes version to install in the jumpbox

# Input the ssh key either as a string or as a file
ssh_key          = "" # The ssh key (string)
ssh_key_pub      = "" # The ssh key (string)
ssh_key_file     = "" # The full path to the file containing the private ssh key
ssh_key_pub_file = "" # The full path to the file containing the public ssh key

tanzu_ova_os = "ubuntu"
```

### Getting the datastore URL
In order to create a Kubernetes storage class for your Tanzu deployment, you will need to get the datastore url from the 
datastore you used in your inputs in phase 1.

3. Run:
```
Set-PowerCLIConfiguration -InvalidCertificateAction:Ignore -Confirm:$false
Connect-VIServer -Server <vCenter address> -User <vCenter user> -Password <vCenter Password>
(Get-Datastore <vSphere datastore>).ExtensionData.info.url  | set-content datastore_url.txt -nonewline
```

### Formatting the NSX ALB default ssl certificate
Extract the SSL-certificate from the phase2/terraform state and write it into a file for Terraform to use it. (Terraform treats the resource "avi_sslkeyandcertificate" 
as one object, and does not allow for querying its attributes)

4. Run:
```
$terraform_state = (Get-Content '..\phase2\terraform.tfstate')
$terraform_state = $terraform_state | ConvertFrom-JSON
$certificate_base64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes(($terraform_state.outputs.cert.value.certificate.certificate).trim()))
$certificate_base64 | set-content default-ssl-cert-base64.txt -nonewline
```
5. Run `terraform init`
6. Run `terraform apply`

## 4. Deploying the TCE clusters
The previous step will finish by prompting the IP address of the deployed jumpbox. SSH into that VM by running:

`ssh -i .\ssh\id_rsa ubuntu@<JUMPBOX_IP_ADDRESS>`

Create a tanzu management cluster by running the following

 ```bash
tanzu management-cluster create --file ~/.config/tanzu/tkg/clusterconfigs/mgmt_cluster_config.yaml -v 8
 ```

### Adding the Tanzu Community Edition repository

In order to install any of the Tanzu packages, it is first necessary to add the Tanzu community edition repository:

 ```bash
tanzu package repository add tce-repo \
--url projects.registry.vmware.com/tce/main:0.9.1 \
--namespace tanzu-package-repo-global
```

Check that the repository was successfully imported:

 ```bash
tanzu package repository list -A
```

#### Create a compute cluster

Create a tanzu management cluster by running the following

 ```bash
tanzu management-cluster create --file ~/.config/tanzu/tkg/clusterconfigs/dev01_cluster_config.yaml -v 8
 ```

Create a kubeconfig in order to access your cluster:

 ```bash
tanzu cluster kubeconfig get dev01 --admin --export-file dev01.kubeconfig
 ```

Connect your workload cluster to a vSphere data store by applying the generated manifest file.

```bash
kubectl apply -f vsphere-storageclass.yml
 ```
