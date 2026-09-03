packer {
  required_plugins {
    proxmox = {
      version = ">= 1.2.0"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

variable "proxmox_api_url" {
  type    = string
  default = "https://pve1.daniellaurin.dev/api2/json"
}

variable "proxmox_api_token_id" {
  type    = string
  default = "terraform-prov@pve!terraform"
}

variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}

variable "packer_temp_password" {
  type      = string
  sensitive = true
}

source "proxmox-iso" "debian13" {
  proxmox_url              = var.proxmox_api_url
  username                 = var.proxmox_api_token_id
  token                    = var.proxmox_api_token_secret
  insecure_skip_tls_verify = true

  node                 = "pve-node1"
  vm_id                = 9000
  vm_name              = "debian13-golden"
  template_description = "Debian 13 golden image, cloud-init + qemu-guest-agent + podman, built ${timestamp()}"


  boot_iso {
    type     = "scsi"
    iso_file = "Proxmox_Archive:iso/debian-13.4.0-amd64-netinst.iso"
    unmount  = true
  }

http_directory    = "http"
  http_bind_address = "0.0.0.0"
  
  boot_wait = "10s"
  boot_command = [
    "<esc><wait>",
    "auto ",
    "url=http://100.84.254.48:{{ .HTTPPort }}/preseed.cfg ",
    "priority=critical ",
    "netcfg/dhcp_timeout=120 ",
    "--- <enter>"
  ]

  os              = "l26"
  cpu_type        = "host"
  scsi_controller = "virtio-scsi-pci"
  qemu_agent      = true

  disks {
    disk_size    = "20G"
    storage_pool = "Proxmox_NFS_Fast"
    type         = "scsi"
  }

  network_adapters {
    bridge   = "vmbr0"
    vlan_tag = "30"
    model    = "virtio"
  }

  cores  = 2
  memory = 2048

  cloud_init              = true
  cloud_init_storage_pool = "Proxmox_NFS_Fast"

  ssh_username = "packer"
  ssh_password = var.packer_temp_password
  ssh_timeout  = "20m"
}

build {
  sources = ["source.proxmox-iso.debian13"]

  provisioner "shell" {
    inline = [
      "echo 'packer ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/packer",
      "sudo apt-get update",
      "sudo apt-get install -y podman",
      "sudo systemctl enable qemu-guest-agent",
      "sudo cloud-init clean --logs",
      "sudo truncate -s 0 /etc/machine-id /var/lib/dbus/machine-id"
    ]
  }
}