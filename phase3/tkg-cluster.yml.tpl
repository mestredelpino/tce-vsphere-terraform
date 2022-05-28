
INFRASTRUCTURE_PROVIDER: vsphere
IDENTITY_MANAGEMENT_TYPE: none
ENABLE_CEIP_PARTICIPATION: "false"
DEPLOY_TKG_ON_VSPHERE7: "true"

VSPHERE_SERVER: "${vcenter-server}"
VSPHERE_USERNAME: "${vcenter-user}"
VSPHERE_PASSWORD: "${vcenter-password}"
VSPHERE_DATACENTER: "${vcenter-datacenter}"
VSPHERE_DATASTORE: "${vcenter-datastore}"
VSPHERE_NETWORK: "${tanzu-workloads-network}"
VSPHERE_RESOURCE_POOL: "${vcenter-resource_pool}"
VSPHERE_FOLDER: "${vcenter-vm_folder}"
VSPHERE_INSECURE: "true"

VSPHERE_CONTROL_PLANE_DISK_GIB: "40"
VSPHERE_CONTROL_PLANE_MEM_MIB: "4096"
VSPHERE_CONTROL_PLANE_NUM_CPUS: "2"

VSPHERE_WORKER_DISK_GIB: "40"
VSPHERE_WORKER_MEM_MIB: "4096"
VSPHERE_WORKER_NUM_CPUS: "2"

CLUSTER_CIDR: 100.96.0.0/11
SERVICE_CIDR: 100.64.0.0/13

AVI_ENABLE: "true"
AVI_CONTROL_PLANE_HA_PROVIDER: "true"
AVI_CLOUD_NAME: "${avi-cloud-name}"
AVI_CONTROLLER: "${avi-controller-ip}"
AVI_DATA_NETWORK: "${avi-data-network-name}"
AVI_DATA_NETWORK_CIDR: "${avi-data-network-cidr}"
AVI_PASSWORD: "${avi-password}"
AVI_USERNAME: "${avi-username}"
AVI_SERVICE_ENGINE_GROUP: "${avi-se-group}"
AVI_CA_DATA_B64: "${avi-ssl-certificate}"

OS_NAME: "${tanzu-ova-os}"




