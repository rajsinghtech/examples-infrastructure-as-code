# Azure Kubernetes Service (AKS) Terraform Example

This example demonstrates how to deploy an Azure Kubernetes Service (AKS) cluster using Terraform. The configuration includes:

- Resource Group
- Virtual Network and Subnet
- AKS Cluster with default node pool
- System-assigned managed identity
- Azure CNI networking

## Prerequisites

1. [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed
2. [Terraform](https://www.terraform.io/downloads.html) installed (version >= 1.0)
3. Azure subscription and appropriate permissions

## Authentication

Before running Terraform, you need to authenticate with Azure. You can do this by running:

```bash
az login
```

## Usage

1. Initialize Terraform:
```bash
terraform init
```

2. Review the planned changes:
```bash
terraform plan
```

3. Apply the configuration:
```bash
terraform apply
```

4. To destroy the infrastructure:
```bash
terraform destroy
```

## Configuration

The example uses variables with default values that can be overridden. You can create a `terraform.tfvars` file to customize the deployment:

```hcl
resource_group_name = "my-aks-rg"
location           = "westeurope"
cluster_name       = "my-production-cluster"
node_count         = 3
vm_size           = "Standard_D4s_v3"
```

## Outputs

After applying the configuration, Terraform will output:
- `kube_config`: The Kubernetes config file (sensitive)
- `cluster_endpoint`: The AKS cluster endpoint
- `cluster_ca_certificate`: The cluster CA certificate (sensitive)
- `cluster_name`: The name of the AKS cluster
- `resource_group_name`: The name of the resource group

## Features

- Azure CNI networking
- System-assigned managed identity
- Auto-scaling enabled by default
- Customizable node pool configuration
- Network security through VNet integration
- Resource tagging support

## Notes

- The default configuration uses `Standard_D2_v2` VMs which are suitable for development/testing
- For production workloads, consider using larger VM sizes and enabling additional security features
- The network configuration uses Azure CNI for better network performance and security 