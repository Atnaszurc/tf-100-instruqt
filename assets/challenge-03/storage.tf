resource "libvirt_volume" "ubuntu_base" {
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

resource "libvirt_volume" "web_disk" {
  name     = "web-server-disk.qcow2"
  pool     = "default"
  capacity = 21474836480
  target = {
    format = {
      type = "qcow2"
    }
  }
  backing_store = {
    path = libvirt_volume.ubuntu_base.id
    format = {
      type = "qcow2"
    }
  }
}

resource "libvirt_volume" "app_disk" {
  name     = "app-server-disk.qcow2"
  pool     = "default"
  capacity = 21474836480
  target = {
    format = {
      type = "qcow2"
    }
  }
  backing_store = {
    path = libvirt_volume.ubuntu_base.id
    format = {
      type = "qcow2"
    }
  }
}

resource "libvirt_volume" "db_disk" {
  name     = "db-server-disk.qcow2"
  pool     = "default"
  capacity = 32212254720
  target = {
    format = {
      type = "qcow2"
    }
  }
  backing_store = {
    path = libvirt_volume.ubuntu_base.id
    format = {
      type = "qcow2"
    }
  }
}

output "storage_info" {
  description = "Storage configuration details"
  value = {
    base_image = libvirt_volume.ubuntu_base.name
    volumes = {
      web = libvirt_volume.web_disk.name
      app = libvirt_volume.app_disk.name
      db  = libvirt_volume.db_disk.name
    }
  }
}
