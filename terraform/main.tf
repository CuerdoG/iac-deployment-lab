terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.60.0"
    }
  }
}

provider "proxmox" {
  endpoint = "https://192.168.1.220:8006/"
  username = "root@pam"
  password = var.pm_password
  insecure = true
}

# Zabbix
resource "proxmox_virtual_environment_container" "Zabbix" {
  node_name    = "pve"
  vm_id        = 202
  unprivileged = true

  cpu {
    cores = 1
  }

  memory {
    dedicated = 512
  }

  disk {
    datastore_id = "local-lvm"
    size         = 8
  }

  network_interface {
    name    = "eth0"
    bridge  = "vmbr1"
    vlan_id = 20
  }

  operating_system {
    template_file_id = "HDD-4TB:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst"
    type             = "debian"
  }

  initialization {
    hostname = "zabbix"
    ip_config {
      ipv4 {
        address = "10.0.20.202/24"
        gateway = "10.0.20.1"
      }
    }
    user_account {
      password = var.ad_password
      keys     = [file("~/.ssh/id_rsa.pub")]
    }
  }

  features {
    nesting = true
  }

  start_on_boot = true
}

# WordPress
resource "proxmox_virtual_environment_container" "Wordpress" {
  node_name    = "pve"
  vm_id        = 203
  unprivileged = true

  cpu {
    cores = 1
  }

  memory {
    dedicated = 768
  }

  disk {
    datastore_id = "local-lvm"
    size         = 10
  }

  network_interface {
    name    = "eth0"
    bridge  = "vmbr1"
    vlan_id = 30
  }

  operating_system {
    template_file_id = "HDD-4TB:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst"
    type             = "debian"
  }

  initialization {
    hostname = "wordpress"
    ip_config {
      ipv4 {
        address = "10.0.30.203/24"
        gateway = "10.0.30.1"
      }
    }
    user_account {
      password = var.ad_password
      keys     = [file("~/.ssh/id_rsa.pub")]
    }
  }

  features {
    nesting = true
  }

  start_on_boot = true
}

# MariaDB
resource "proxmox_virtual_environment_container" "MariaDB" {
  node_name    = "pve"
  vm_id        = 204
  unprivileged = true

  cpu {
    cores = 1
  }

  memory {
    dedicated = 512
  }

  disk {
    datastore_id = "local-lvm"
    size         = 10
  }

  network_interface {
    name    = "eth0"
    bridge  = "vmbr1"
    vlan_id = 40
  }

  operating_system {
    template_file_id = "HDD-4TB:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst"
    type             = "debian"
  }

  initialization {
    hostname = "mariadb"
    ip_config {
      ipv4 {
        address = "10.0.40.204/24"
        gateway = "10.0.40.1"
      }
    }
    user_account {
      password = var.ad_password
      keys     = [file("~/.ssh/id_rsa.pub")]
    }
  }

  features {
    nesting = true
  }

  start_on_boot = true
}

# TeamPass
resource "proxmox_virtual_environment_container" "TeamPass" {
  node_name    = "pve"
  vm_id        = 205
  unprivileged = true

  cpu {
    cores = 1
  }

  memory {
    dedicated = 512
  }

  disk {
    datastore_id = "local-lvm"
    size         = 8
  }

  network_interface {
    name    = "eth0"
    bridge  = "vmbr1"
    vlan_id = 10
  }

  operating_system {
    template_file_id = "HDD-4TB:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst"
    type             = "debian"
  }

  initialization {
    hostname = "teampass"
    ip_config {
      ipv4 {
        address = "10.0.10.205/24"
        gateway = "10.0.10.1"
      }
    }
    user_account {
      password = var.ad_password
      keys     = [file("~/.ssh/id_rsa.pub")]
    }
  }

  features {
    nesting = true
  }

  start_on_boot = true
}

# Traefik
resource "proxmox_virtual_environment_container" "Traefik" {
  node_name    = "pve"
  vm_id        = 206
  unprivileged = true

  cpu {
    cores = 1
  }

  memory {
    dedicated = 256
  }

  disk {
    datastore_id = "local-lvm"
    size         = 4
  }

  network_interface {
    name    = "eth0"
    bridge  = "vmbr1"
    vlan_id = 30
  }

  operating_system {
    template_file_id = "HDD-4TB:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst"
    type             = "debian"
  }

  initialization {
    hostname = "traefik"
    ip_config {
      ipv4 {
        address = "10.0.30.206/24"
        gateway = "10.0.30.1"
      }
    }
    user_account {
      password = var.ad_password
      keys     = [file("~/.ssh/id_rsa.pub")]
    }
  }

  features {
    nesting = true
  }

  start_on_boot = true
}

# Bastion
resource "proxmox_virtual_environment_vm" "bastion" {
  name      = "Bastion"
  node_name = "pve"
  vm_id     = 207

  clone {
    vm_id = 9100
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
  }

  network_device {
    bridge = "vmbr1"
    vlan_id = 10
  }

  initialization {
    ip_config {
      ipv4 {
        address = "10.0.10.207/24"
        gateway = "10.0.10.1"
      }
    }

    user_account {
      username = "admin"
      password = var.ad_password
      keys     = [file("~/.ssh/id_rsa.pub")]
    }
  }
}
