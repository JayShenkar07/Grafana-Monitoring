#!/bin/bash

# Exit the script if any command fails
set -e

# Function to install Helm
install_helm() {
  echo "Checking if Helm is installed..."
  if ! command -v helm &> /dev/null; then
    echo "Helm is not installed. Installing Helm..."
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
  else
    echo "Helm is already installed."
  fi
}

# Function to add necessary Helm repositories
add_helm_repos() {
  echo "Adding Grafana Helm repository..."
  helm repo add grafana https://grafana.github.io/helm-charts
  helm repo update
}

# Function to create a namespace
create_namespace() {
  local namespace=$1
  echo "Creating namespace: $namespace"
  kubectl create namespace $namespace || echo "Namespace $namespace already exists."
}

install_loki() {
  echo "Installing Loki..."
  helm install --values Loki/values.yaml loki --namespace=loki grafana/loki
}

install_tempo() {
  echo "Installing Tempo..."
  helm install tempo grafana/tempo --namespace monitoring
}

install_grafana() {
  echo "Installing Grafana..."
  kubectl apply -f Grafana/grafana.yaml --namespace=monitoring 
}

install_promtail() {
  echo "Installing Promtail..."
  kubectl apply -f Promtail/promtail-deamonset.yaml #Installs in default namespace
}

# Main script execution
main() {
  # Install Helm
  install_helm

  # Add Helm repositories
  add_helm_repos

  create_namespace "loki"
  create_namespace "tempo"
  create_namespace "monitoring" #grafana 

  # Install Loki, Tempo, and Grafana
  install_loki
  install_tempo
  install_grafana
  install_promtail
  echo "Grafana, Loki,Promtail, and Tempo have been successfully installed on the cluster."
}

# Run the main function
main
