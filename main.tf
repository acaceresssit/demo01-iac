## Azure resource provider ##
provider azurerm {
  version = "=2.36.0"
  features {}
}

## Azure resource group for the kubernetes cluster ##
resource "azurerm_resource_group" "iac" {
  name = var.resource_group_name
  location = var.location
}

## Private key for the kubernetes cluster ##
resource "tls_private_key" "iac" {
  algorithm = "RSA"
}

## Save the private key in the local workspace ##
resource "null_resource" "iac" {
  triggers = {
    key = tls_private_key.iac.private_key_pem
  }

  provisioner "local-exec" {
    command = <<EOF
      mkdir -p ${path.module}/.ssh
      echo "${tls_private_key.iac.private_key_pem}" > ${path.module}/.ssh/id_rsa
      chmod 0600 ${path.module}/.ssh/id_rsa
EOF
  }
}

## AKS kubernetes cluster ##
resource "azurerm_kubernetes_cluster" "iac" {
    name = var.cluster_name
    resource_group_name = azurerm_resource_group.iac.name
    location = azurerm_resource_group.iac.location
    dns_prefix = var.dns_prefix

    linux_profile {
        admin_username = var.admin_username
        ## SSH key is generated using "tls_private_key" resource
        ssh_key {
            key_data = "${trimspace(tls_private_key.iac.public_key_openssh)} ${var.admin_username}@azure.com"
        }
    }
    default_node_pool {
        name = "default"
        node_count = var.agent_count
        vm_size = "Standard_D2_v2"      
    }
    identity {
        type = "SystemAssigned"      
    }
    tags = {
        Environment = "Develop"
    }

}



##############################################################
# Módulo de creación de AKS
##############################################################

resource "local_file" "cluster_credentials" {
  count             = var.agent_count
  sensitive_content = azurerm_kubernetes_cluster.iac.kube_config_raw
  filename          = "${var.output_directory}/${var.kubeconfig_filename}"

  depends_on = [azurerm_kubernetes_cluster.iac]
}
## Outputs ##

# Example attributes available for output
output "id" {
    value = azurerm_kubernetes_cluster.iac.id
}

output "client_key" {
  value = azurerm_kubernetes_cluster.iac.kube_config.0.client_key
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.iac.kube_config.0.client_certificate
}

output "cluster_ca_certificate" {
  value = azurerm_kubernetes_cluster.iac.kube_config.0.cluster_ca_certificate
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.iac.kube_config_raw
  sensitive = true
}

output "host" {
  value = azurerm_kubernetes_cluster.iac.kube_config.0.host
}

output "kubeconfig_done" {
  value = join("", local_file.cluster_credentials.*.id)
}

output "kube_admin_config"{
  sensitive = true
  value = azurerm_kubernetes_cluster.iac.kube_config
}