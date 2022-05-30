#!/bin/sh
. /home/ubuntu/.env

# Generate a SSH keypair.
if ! [ -f /home/ubuntu/.ssh/id_rsa ]; then echo "true"
  ssh-keygen -t rsa -f /home/ubuntu/.ssh/id_rsa -q -P ''
fi

# Install kubectl

if [ -f /home/ubuntu/kubectl-cli.gz ]; then
  gzip -d /home/ubuntu/kubectl-cli.gz
  chmod +x /home/ubuntu/kubectl-cli
  sudo mv /home/ubuntu/kubectl-cli /bin/kubectl
fi

#
curl -LO https://dl.k8s.io/release/v$kubectl_version/bin/linux/amd64/kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm /home/ubuntu/kubectl
#


if [ -f /home/ubuntu/$tanzu_cli ]; then
  tar -xvf /home/ubuntu/"$tanzu_cli"
  sudo install cli/core/v0.*.*/tanzu-core-linux_amd64 /usr/local/bin/tanzu
  tce_folder=$(basename "$tanzu_cli" .tar.gz) && \
  ./$tce_folder/install.sh
  rm $tanzu_cli
  rm $tce_folder -rf
fi

# Configure TKG.
if [ -f /home/ubuntu/tkg-cluster.yml ]; then
  tanzu init > /dev/null 2>&1
  tanzu management-cluster create > /dev/null 2>&1
  mkdir -p ~/.config/tanzu/tkg/clusterconfigs
  cat /home/ubuntu/tkg-cluster.yml >> ~/.config/tanzu/tkg/config.yaml
  SSH_PUBLIC_KEY=`cat /home/ubuntu/.ssh/id_rsa.pub`
  cat <<EOF >> ~/.config/tanzu/tkg/config.yaml
VSPHERE_SSH_AUTHORIZED_KEY: "$SSH_PUBLIC_KEY"
EOF
  cat <<EOF >> ~/.config/tanzu/tkg/clusterconfigs/mgmt_cluster_config.yaml
CLUSTER_NAME: mgmt
CLUSTER_PLAN: dev
EOF
    cat <<EOF >> ~/tkg_services_cluster_config.yaml
CLUSTER_NAME: tkg-services
CLUSTER_PLAN: dev
EOF
    cat <<EOF >> ~/dev01_cluster_config.yaml
CLUSTER_NAME: dev01
CLUSTER_PLAN: dev
EOF
  mv ~/tkg_services_cluster_config.yaml ~/.config/tanzu/tkg/clusterconfigs/tkg_services_cluster_config.yaml
  mv ~/dev01_cluster_config.yaml ~/.config/tanzu/tkg/clusterconfigs/dev01_cluster_config.yaml
  /bin/rm -f /home/ubuntu/tkg-cluster.yml
  rm /home/ubuntu/tanzu
fi

# Configure VIm.
if ! [ -f /home/ubuntu/.vimrc ]; then
  cat <<EOF >> /home/ubuntu/.vimrc
set ts=2
set sw=2
set ai
set et
EOF
fi

# Install Docker.
sudo apt-get update && \
sudo apt-get -y install docker.io && \
sudo ln -sf /usr/bin/docker.io /usr/local/bin/docker && \
sudo usermod -aG docker ubuntu

# Install kind to be able to clean up the environment in case of deployment failure
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Install yq and jq
sudo apt update
sudo snap install yq
sudo apt install -y jq

# Install Carvel tools
wget -O- https://carvel.dev/install.sh > install.sh
sudo bash install.sh
rm install.sh

# Install MinIO cli
wget https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x mc

# Install ArgoCD cli

sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo chmod +x /usr/local/bin/argocd

# Install Tekton cli
sudo apt update;sudo apt install -y gnupg
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3EFE0E0A2F2F60AA
echo "deb http://ppa.launchpad.net/tektoncd/cli/ubuntu eoan main"|sudo tee /etc/apt/sources.list.d/tektoncd-ubuntu-cli.list
sudo apt update && sudo apt install -y tektoncd-cli

# Install Helm
sudo snap install helm --classic