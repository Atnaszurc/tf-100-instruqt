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

# Create volumes using for_each
resource "libvirt_volume" "vm_disk" {
  for_each = local.vm_configs

  name     = "${each.value.name}-disk.qcow2"
  pool     = "default"
  capacity = each.value.disk_size
  target = {
    format = {
      type = "qcow2"
    }
  }
}

# Create VMs using for_each
resource "libvirt_domain" "vm" {
  for_each = local.vm_configs

  name   = each.value.name
  memory = each.value.memory
  vcpu   = each.value.vcpu
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
          volume = libvirt_volume.vm_disk[each.key].id
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

# Create a file with VM information using terraform_data
resource "terraform_data" "vm_info" {
  provisioner "local-exec" {
    command = <<-EOT
      cat > vm_inventory.txt << 'INVENTORY'
# VM Inventory - ${var.environment} Environment
# Generated: ${timestamp()}
# Tags: ${local.tag_string}

${join("\n", [for k, v in local.vm_configs : "- ${v.name}: ${v.memory}MB RAM, ${v.vcpu} vCPU"])}
INVENTORY
    EOT
  }

  triggers_replace = {
    vm_configs = jsonencode(local.vm_configs)
  }
}
