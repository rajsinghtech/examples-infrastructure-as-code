locals {
  name = "example-${basename(path.cwd)}"

  azure_tags = {
    Name = local.name
  }

  tailscale_acl_tags = [
    "tag:k8s-operator",
    "tag:k8s",
  ]

  // Modify these to use your own settings
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  vpc_cidr_block            = module.vpc.vnet_address_space
  vpc_id                    = module.vpc.vnet_id
  subnet_id                 = module.vpc.private_subnet_id
  network_security_group_id = azurerm_network_security_group.tailscale_ingress.id

  # AKS cluster settings
  kubernetes_version = "1.29"
  node_count        = 2
  node_vm_size      = "Standard_D2s_v3"
}

resource "azurerm_resource_group" "main" {
  location = "centralus"
  name     = local.name
}

module "vpc" {
  source = "../internal-modules/azure-network"

  name = local.name
  tags = local.azure_tags

  location            = local.location
  resource_group_name = local.resource_group_name

  cidrs = ["10.0.0.0/22"]
  subnet_cidrs = [
    "10.0.0.0/24",
    "10.0.1.0/24",
    "10.0.2.0/24",
  ]
  subnet_name_public               = "public"
  subnet_name_private              = "private"
  subnet_name_private_dns_resolver = "dns-inbound"
}

#
# AKS Cluster
#
resource "azurerm_kubernetes_cluster" "main" {
  name                = local.name
  location            = local.location
  resource_group_name = local.resource_group_name
  dns_prefix          = local.name
  kubernetes_version  = local.kubernetes_version

  default_node_pool {
    name           = "default"
    node_count     = local.node_count
    vm_size        = local.node_vm_size
    vnet_subnet_id = local.subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  tags = local.azure_tags
}

#
# Tailscale Kubernetes Operator
#
resource "helm_release" "tailscale_operator" {
  name       = "tailscale-operator"
  repository = "https://pkgs.tailscale.com/helmcharts"
  chart      = "tailscale-operator"
  namespace  = "tailscale"

  create_namespace = true
  wait             = true

  set_sensitive {
    name  = "oauth.clientId"
    value = var.tailscale_oauth_client_id
  }

  set_sensitive {
    name  = "oauth.clientSecret"
    value = var.tailscale_oauth_client_secret
  }

  depends_on = [azurerm_kubernetes_cluster.main]
}

#
# Network Security Group for Tailscale
#
resource "azurerm_network_security_group" "tailscale_ingress" {
  location            = local.location
  resource_group_name = local.resource_group_name

  name = "nsg-tailscale-ingress"

  security_rule {
    name                       = "AllowTailscaleInbound"
    access                     = "Allow"
    direction                  = "Inbound"
    priority                   = 100
    protocol                   = "Udp"
    source_address_prefix      = "Internet"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "41641"
  }

  tags = local.azure_tags
}

# Associate the NSG with the subnet
resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = local.subnet_id
  network_security_group_id = local.network_security_group_id
} 