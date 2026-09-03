provider "proxmox" {
  endpoint  = "https://10.0.10.11:8006/"
  api_token = var.proxmox_api_token
  insecure  = true

  ssh {
    agent    = true
    username = "root"
  }
}