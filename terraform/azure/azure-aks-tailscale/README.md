# azure-aks-tailscale

This example creates the following:

- a Virtual Network with `public`, `private`, and `dns-inbound` subnets using the [Azure RM Module for Network](https://registry.terraform.io/modules/Azure/network/azurerm/latest)
from the Terraform Registry
- an Azure NAT Gateway associated with the `private` subnet
- an Azure DNS Private Resolver in the `dns-inbound` subnet
- an Azure Kubernetes Service (AKS) cluster running in the private subnet
- the Tailscale Kubernetes Operator deployed via Helm
- a network security group configured for Tailscale traffic

The AKS cluster is configured with:
- 2 worker nodes (Standard_D2s_v3)
- Azure CNI networking
- System-assigned managed identity
- Kubernetes version 1.29

The Tailscale Kubernetes Operator is installed using the official Helm chart and configured with OAuth credentials for authentication.

## Prerequisites

Before using this example, you need:

1. **Azure CLI** configured and authenticated
2. **Tailscale account** with admin access
3. **OAuth client credentials** from Tailscale admin console

### Setting up Tailscale OAuth credentials

1. In your Tailscale admin console, go to the **OAuth clients** page
2. Create a new OAuth client with the following scopes:
   - `Devices Core` (write access)
   - `Auth Keys` (write access)
3. Set the tag to `tag:k8s-operator`
4. Note down the client ID and secret for use in the next steps

You'll also need to configure your tailnet policy file to include the required tags:

```json
{
  "tagOwners": {
    "tag:k8s-operator": [],
    "tag:k8s": ["tag:k8s-operator"]
  }
}
```

## To use

Follow the documentation to configure the Terraform providers:

- [Azure](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Helm](https://registry.terraform.io/providers/hashicorp/helm/latest/docs)
- [Kubernetes](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)

### Deploy

1. Set your Tailscale OAuth credentials as environment variables:

```shell
export TF_VAR_tailscale_oauth_client_id="your_client_id"
export TF_VAR_tailscale_oauth_client_secret="your_client_secret"
```

2. Initialize and apply the Terraform configuration:

```shell
terraform init
terraform apply
```

3. Configure kubectl to connect to your new cluster:

```shell
az aks get-credentials --resource-group $(terraform output -raw resource_group_name) --name $(terraform output -raw kubernetes_cluster_name)
```

4. Verify the Tailscale operator is running:

```shell
kubectl get pods -n tailscale
```

5. Check that the operator has joined your tailnet by looking in the **Machines** page of the Tailscale admin console for a device named **tailscale-operator**.

## What you can do next

With the Tailscale Kubernetes Operator installed, you can:

- **Expose services to your tailnet** using Tailscale ingress
- **Connect to external services** via Tailscale egress
- **Set up subnet routers** to access the entire cluster network
- **Deploy exit nodes** for internet access through your tailnet

For more information, see the [Tailscale Kubernetes Operator documentation](https://tailscale.com/kb/1236/kubernetes-operator).

## To destroy

```shell
terraform destroy
```

## Security considerations

- The AKS cluster is deployed in a private subnet and not directly accessible from the internet
- Tailscale traffic is allowed through the network security group on UDP port 41641
- OAuth credentials are marked as sensitive in Terraform and should be stored securely
- The cluster uses Azure CNI for networking and system-assigned managed identity for Azure resource access 