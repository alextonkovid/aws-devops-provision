#!/bin/bash

# Define URLs and variables
K3S_URL="https://get.k3s.io"
HELM_SCRIPT_URL="https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3"
CHART="jenkinsci/jenkins"
NAMESPACE="jenkins"

# Function to check the success of the last command
check_command() {
    if [[ $? -ne 0 ]]; then
        echo "Error: $1 failed"
        exit 1
    fi
}

pwd

# Update and upgrade system packages
echo "Updating and upgrading system packages..."
sudo apt update -y && sudo apt upgrade -y
check_command "System update and upgrade"

# Install K3s
echo "Installing K3s..."
curl -sfL $K3S_URL | sh -s - --write-kubeconfig-mode 644
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

# Add Jenkins Helm repo and update
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
helm install jenkins -n $NAMESPACE -f jenkins-values.yaml $CHART
check_command "Helm installation of Jenkins"

# Retrieve Jenkins admin password
echo "Retrieving Jenkins admin password..."
jsonpath="{.data.jenkins-admin-password}"
secret=$(kubectl get secret -n $NAMESPACE jenkins -o jsonpath=$jsonpath)
check_command "Getting Jenkins admin password secret"

# Decode and display the admin password
echo "Jenkins admin password:"
echo $(echo $secret | base64 --decode)

# Wait until the directory is created
while [ ! -d "/data/jenkins-volume" ]; do
    echo "Waiting for /data/jenkins-volume to be created..."
    sleep 2
done

sudo chmod -R 777 /data/jenkins-volume

echo "Done!"
