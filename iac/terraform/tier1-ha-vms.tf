resource "proxmox_hagroup" "critical" {
  group      = "critical"
  nodes      = { "pve-node1" = 2, "pve-node2" = 1, "pve-node3" = 1 }
  restricted = true
}

resource "proxmox_virtual_environment_vm" "vm_102_pihole_secondary" {
  name      = "pihole-secondary"
  node_name = "pve-node2"
  vm_id     = 102

  clone {
    vm_id = 9000
    full  = true
  }

  cpu    { cores = 1 }
  memory { dedicated = 512 }

  network_device {
    bridge  = "vmbr0"
    vlan_id = 30
  }

  initialization {
    datastore_id = "Proxmox_NFS_Fast"
    ip_config {
      ipv4 {
        address = "10.0.30.11/24"
        gateway = "10.0.30.1"
      }
    }
    dns {
      servers = ["10.0.30.9"]
    }
    user_account {
      username = "adm-deb"
      keys = [trimspace(file(pathexpand(var.ssh_public_key)))]
    }
  }

  tags = ["tier1", "pihole", "dns"]
}

resource "proxmox_haresource" "vm_102" {
  resource_id = "vm:${proxmox_virtual_environment_vm.vm_102_pihole_secondary.vm_id}"
  group       = proxmox_hagroup.critical.group
  state       = "started"
  comment     = "Managed by Terraform"
}