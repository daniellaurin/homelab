resource "proxmox_download_file" "debian13_lxc" {
  content_type = "vztmpl"
  datastore_id = "local"
  node_name    = "pve-node1"
  url          = "http://download.proxmox.com/images/system/debian-13-standard_13.1-2_amd64.tar.zst"
}

# LXC 201 — Arr Stack (Includes native /dev/net/tun passthrough for Gluetun)
resource "proxmox_virtual_environment_container" "lxc_201_arr" {
  provider     = proxmox.root_lxc
  node_name    = "pve-node1"
  vm_id        = 261
  unprivileged = false

  operating_system {
    template_file_id = proxmox_download_file.debian13_lxc.id
    type             = "debian"
  }

  disk {
    datastore_id = "Proxmox_NFS_Fast"
    size         = 20
  }

  cpu    { cores = 4 }
  memory { dedicated = 4096 }

  network_interface {
    name    = "eth0"
    bridge  = "vmbr0"
    vlan_id = 30
  }

  initialization {
    hostname = "arr-stack"
    ip_config {
      ipv4 {
        address = "10.0.30.50/24"
        gateway = "10.0.30.1"
      }
    }
    user_account {
      keys = [trimspace(file(pathexpand(var.ssh_public_key)))]
    }
  }

  # Native /dev/net/tun passthrough for Gluetun VPN
  device_passthrough {
    path = "/dev/net/tun"
    mode = "0666"
  }

  mount_point {
    volume = "/mnt/data/lxc-arr"
    path   = "/opt/appdata"
  }

  mount_point {
    volume = "/mnt/data/jellyfin-library" # might not need it as not stateless
    path   = "/data"
  }

  features {
    nesting = true
  }
}

# LXC 208 — FileBrowser
resource "proxmox_virtual_environment_container" "lxc_208_filebrowser" {
  provider     = proxmox.root_lxc
  node_name    = "pve-node1"
  vm_id        = 299
  unprivileged = false

  operating_system {
    template_file_id = proxmox_download_file.debian13_lxc.id
    type             = "debian"
  }

  disk {
    datastore_id = "Proxmox_NFS_Fast"
    size         = 15
  }

  cpu    { cores = 2 }
  memory { dedicated = 2048 }

  network_interface {
    name    = "eth0"
    bridge  = "vmbr0"
    vlan_id = 30
  }

  initialization {
    hostname = "filebrowser"
    ip_config {
      ipv4 {
        address = "10.0.30.65/24"
        gateway = "10.0.30.1"
      }
    }
    user_account {
      keys = [trimspace(file(pathexpand(var.ssh_public_key)))]
    }
  }

  mount_point {
    volume = "/mnt/data/lxc-files"
    path   = "/opt/appdata"
  }

  features {
    nesting = true
  }
}