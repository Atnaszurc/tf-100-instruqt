terraform {
  required_version = ">= 1.0"

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.9"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

# Base image
resource "libvirt_volume" "base" {
  name = "ubuntu-22.04-base.qcow2"
  pool = "default"

  create = {
    content = {
      url = "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"
    }
  }

  target = {
    format = {
      type = "qcow2"
    }
  }
}

# Network
resource "libvirt_network" "app_network" {
  name      = "${var.environment}-network"
  autostart = true
}

# VM volumes
resource "libvirt_volume" "web_disk" {
  name     = "${var.environment}-web-disk.qcow2"
  pool     = "default"
  capacity = var.vm_specs[var.environment].web.disk_size

  target = {
    format = {
      type = "qcow2"
    }
  }

  backing_store = {
    path = libvirt_volume.base.id
    format = {
      type = "qcow2"
    }
  }
}

resource "libvirt_volume" "app_disk" {
  name     = "${var.environment}-app-disk.qcow2"
  pool     = "default"
  capacity = var.vm_specs[var.environment].app.disk_size

  target = {
    format = {
      type = "qcow2"
    }
  }

  backing_store = {
    path = libvirt_volume.base.id
    format = {
      type = "qcow2"
    }
  }
}

resource "libvirt_volume" "db_disk" {
  name     = "${var.environment}-db-disk.qcow2"
  pool     = "default"
  capacity = var.vm_specs[var.environment].db.disk_size

  target = {
    format = {
      type = "qcow2"
    }
  }

  backing_store = {
    path = libvirt_volume.base.id
    format = {
      type = "qcow2"
    }
  }
}

# VMs
resource "libvirt_domain" "web" {
  name   = "${var.environment}-web"
  memory = var.vm_specs[var.environment].web.memory
  vcpu   = var.vm_specs[var.environment].web.vcpu
  type   = "kvm"

  os = {
    type         = "hvm"
    type_arch    = "x86_64"
    type_machine = "pc"
  }

  devices = {
    disks = [{
      source = {
        volume = {
          pool   = "default"
          volume = libvirt_volume.web_disk.id
        }
      }
      target = {
        dev = "vda"
        bus = "virtio"
      }
    }]

    interfaces = [{
      network = {
        network = libvirt_network.app_network.name
      }
      model = {
        type = "virtio"
      }
      wait_for_lease = true
    }]

    console = [{
      type = "pty"
      target = {
        type = "serial"
        port = 0
      }
    }]
  }
}

resource "libvirt_domain" "app" {
  name   = "${var.environment}-app"
  memory = var.vm_specs[var.environment].app.memory
  vcpu   = var.vm_specs[var.environment].app.vcpu
  type   = "kvm"

  os = {
    type         = "hvm"
    type_arch    = "x86_64"
    type_machine = "pc"
  }

  devices = {
    disks = [{
      source = {
        volume = {
          pool   = "default"
          volume = libvirt_volume.app_disk.id
        }
      }
      target = {
        dev = "vda"
        bus = "virtio"
      }
    }]

    interfaces = [{
      network = {
        network = libvirt_network.app_network.name
      }
      model = {
        type = "virtio"
      }
      wait_for_lease = true
    }]

    console = [{
      type = "pty"
      target = {
        type = "serial"
        port = 0
      }
    }]
  }
}

resource "libvirt_domain" "db" {
  name   = "${var.environment}-db"
  memory = var.vm_specs[var.environment].db.memory
  vcpu   = var.vm_specs[var.environment].db.vcpu
  type   = "kvm"

  os = {
    type         = "hvm"
    type_arch    = "x86_64"
    type_machine = "pc"
  }

  devices = {
    disks = [{
      source = {
        volume = {
          pool   = "default"
          volume = libvirt_volume.db_disk.id
        }
      }
      target = {
        dev = "vda"
        bus = "virtio"
      }
    }]

    interfaces = [{
      network = {
        network = libvirt_network.app_network.name
      }
      model = {
        type = "virtio"
      }
      wait_for_lease = true
    }]

    console = [{
      type = "pty"
      target = {
        type = "serial"
        port = 0
      }
    }]
  }
}
