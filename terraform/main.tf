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
resource "proxmox_virtual_environment_vm" "zabbix" {
  name      = "Zabbix"
  node_name = "pve"
  vm_id     = 202

  clone {
    vm_id = 9000
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
  }

  network_device {
    bridge  = "vmbr1"
    vlan_id = 20
  }

  initialization {
    ip_config {
      ipv4 {
        address = "10.0.20.202/24"
        gateway = "10.0.20.1"
      }
    }
    user_account {
      username = "admin"
      password = var.ad_password
      keys     = [file("~/.ssh/id_rsa.pub")]
    }
  }
}

# Wordpress
resource "proxmox_virtual_environment_vm" "wordpress" {
  name      = "WordPress"
  node_name = "pve"
  vm_id     = 203

  clone {
    vm_id = 9000
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
  }

  network_device {
    bridge  = "vmbr1"
    vlan_id = 30
  }

  initialization {
    ip_config {
      ipv4 {
        address = "10.0.30.203/24"
        gateway = "10.0.30.1"
      }
    }
    user_account {
      username = "admin"
      password = var.ad_password
      keys     = [file("~/.ssh/id_rsa.pub")]
    }
  }
}

# MariaDB
resource "proxmox_virtual_environment_vm" "mariadb" {
  name      = "MariaDB"
  node_name = "pve"
  vm_id     = 204

  clone {
    vm_id = 9000
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
  }

  network_device {
    bridge  = "vmbr1"
    vlan_id = 40
  }

  initialization {
    ip_config {
      ipv4 {
        address = "10.0.40.204/24"
        gateway = "10.0.40.1"
      }
    }
    user_account {
      username = "admin"
      password = var.ad_password
      keys     = [file("~/.ssh/id_rsa.pub")]
    }
  }
}