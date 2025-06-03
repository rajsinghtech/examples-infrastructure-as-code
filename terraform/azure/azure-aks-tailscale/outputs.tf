output "resource_group_name" {
  description = "Name of the Azure resource group"
  value       = azurerm_resource_group.main.name
}

output "kubernetes_cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.name
}

output "kubernetes_cluster_id" {
  description = "ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.id
}

output "kube_config" {
  description = "Kubernetes config for connecting to the cluster"
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true
}

output "vpc_id" {
  description = "ID of the virtual network"
  value       = module.vpc.vnet_id
}

output "nat_public_ips" {
  description = "Public IPs of the NAT gateway"
  value       = module.vpc.nat_public_ips
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = module.vpc.public_subnet_id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = module.vpc.private_subnet_id
}

output "private_dns_resolver_inbound_endpoint_ip" {
  description = "IP address of the private DNS resolver inbound endpoint"
  value       = module.vpc.private_dns_resolver_inbound_endpoint_ip
}

output "tailscale_operator_namespace" {
  description = "Kubernetes namespace where Tailscale operator is deployed"
  value       = helm_release.tailscale_operator.namespace
} 