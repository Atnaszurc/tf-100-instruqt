resource "libvirt_domain" "web_server" {
  name   = "web-server"
  memory = 1024
  vcpu   = 1
  type   = "kvm"

  os = {
    type         = "hvm"
    type_arch    = "x86_64"
    type_machine = "pc"
  }

  devices = {
    disks = [
      {
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
      }
    ]
    interfaces = [
      {
        network = {
          network = libvirt_network.app_network.name
        }
        model = {
          type = "virtio"
        }
        wait_for_lease = true
      }
    ]
    console = [
      {
        type = "pty"
        target = {
          port = 0
          type = "serial"
        }
      }
    ]
  }
}

resource "libvirt_domain" "app_server" {
  name   = "app-server"
  memory = 1024
  vcpu   = 1
  type   = "kvm"

  os = {
    type         = "hvm"
    type_arch    = "x86_64"
    type_machine = "pc"
  }

  devices = {
    disks = [
      {
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
      }
    ]
    interfaces = [
      {
        network = {
          network = libvirt_network.app_network.name
        }
        model = {
          type = "virtio"
        }
        wait_for_lease = true
      }
    ]
    console = [
      {
        type = "pty"
        target = {
          port = 0
          type = "serial"
        }
      }
    ]
  }
}

resource "libvirt_domain" "db_server" {
  name   = "db-server"
  memory = 2048
  vcpu   = 2
  type   = "kvm"

  os = {
    type         = "hvm"
    type_arch    = "x86_64"
    type_machine = "pc"
  }

  devices = {
    disks = [
      {
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
      }
    ]
    interfaces = [
      {
        network = {
          network = libvirt_network.app_network.name
        }
        model = {
          type = "virtio"
        }
        wait_for_lease = true
      }
    ]
    console = [
      {
        type = "pty"
        target = {
          port = 0
          type = "serial"
        }
      }
    ]
  }
}
