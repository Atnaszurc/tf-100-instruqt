# Storage resources - base image and VM disks

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
