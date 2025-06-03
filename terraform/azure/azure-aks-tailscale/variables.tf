#
# Variables for Tailscale OAuth credentials
#
variable "tailscale_oauth_client_id" {
  description = "Tailscale OAuth client ID for the Kubernetes operator"
  type        = string
  sensitive   = true
}

variable "tailscale_oauth_client_secret" {
  description = "Tailscale OAuth client secret for the Kubernetes operator"
  type        = string
  sensitive   = true
} 