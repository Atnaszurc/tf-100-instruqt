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

# Simple VM for state practice
resource "libvirt_volume" "disk" {
  name = "state-demo-disk.qcow2"
  pool = "default"

  capacity = 10737418240

  target = {
    format = {
      type = "qcow2"
    }
  }
}

resource "libvirt_domain" "vm" {
  name   = "state-demo-vm"
  memory = 1024
  vcpu   = 1
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
          volume = libvirt_volume.disk.id
        }
      }
      target = {
        dev = "vda"
        bus = "virtio"
      }
    }]

    interfaces = [{
      network = {
        network_name = "default"
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

output "vm_info" {
  value = {
    name   = libvirt_domain.vm.name
    memory = libvirt_domain.vm.memory
    vcpu   = libvirt_domain.vm.vcpu
    id     = libvirt_domain.vm.id
  }
}
