#!/bin/bash

# Define URLs and variables
K3S_URL="https://get.k3s.io"
HELM_SCRIPT_URL="https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3"


# Function to check the success of the last command
check_command() {
    if [[ $? -ne 0 ]]; then
        echo "Error: $1 failed"
        exit 1
    fi
}

# Update and upgrade system packages
echo "Updating and upgrading system packages..."
sudo apt update -y && sudo apt upgrade -y
check_command "System update and upgrade"

# Install Docker
echo "Installing Docker..."
curl https://releases.rancher.com/install-docker/20.10.sh | sh
check_command "Docker installation"

# Install K3s
echo "Installing K3s..."
curl -sfL $K3S_URL | sh -s - --docker --write-kubeconfig-mode 644
check_command "K3s installation"

# Download and install Helm
echo "Downloading and installing Helm..."
curl -fsSL -o get_helm.sh $HELM_SCRIPT_URL
check_command "Downloading Helm script"

chmod 700 get_helm.sh
./get_helm.sh
check_command "Helm installation"

# Set KUBECONFIG environment variable
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

helm repo add bitnami https://charts.bitnami.com/bitnami
helm upgrade --install prometheus bitnami/kube-prometheus \
  --set prometheus.service.type=NodePort \
  --set prometheus.service.nodePorts.http=32002

# Add Helm repo and update

helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube

echo "Adding Jenkins Helm repository and updating..."
helm repo add jenkinsci https://charts.jenkins.io
check_command "Adding Jenkins Helm repository"

helm repo update
check_command "Updating Helm repositories"

# Apply Kubernetes configurations
cd /tmp/data/kubernetes/

echo "Applying Kubernetes configurations..."
kubectl apply -f jenkins-volume.yaml
check_command "Applying jenkins-volume.yaml"

# Create jenkins ns
kubectl create ns jenkins

kubectl apply -f jenkins-sa.yaml
check_command "Applying jenkins-sa.yaml"

# Install Jenkins using Helm
echo "Installing Jenkins using Helm..."
sudo mkdir -p /data/jenkins-volume
sudo chmod -R 777 /data/jenkins-volume
helm install jenkins -n $NAMESPACE -f jenkins-values.yaml $CHART
# Retrieve Jenkins admin password
jsonpath="{.data.jenkins-admin-password}"
secret=$(kubectl get secret -n $NAMESPACE jenkins -o jsonpath=$jsonpath)

# # Install Sonar using Helm
# echo "Installing Sonar using Helm..."
# kubectl create namespace sonarqube
# helm upgrade --install -n sonarqube sonarqube sonarqube/sonarqube
# check_command "Helm installation"

# echo "Unified memory setup"
# sudo bash ./memory-expand.sh

# Decode and display the admin password
echo "Jenkins admin password:"
echo $(echo $secret | base64 --decode)

echo "Done!"
