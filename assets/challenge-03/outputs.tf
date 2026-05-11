output "vm_names" {
  description = "Names of all VMs"
  value = {
    web_server = libvirt_domain.web_server.name
    app_server = libvirt_domain.app_server.name
    db_server  = libvirt_domain.db_server.name
  }
}

output "infrastructure_summary" {
  description = "Complete infrastructure overview"
  value = {
    network = {
      name = libvirt_network.app_network.name
    }
    vms = {
      web = {
        name   = libvirt_domain.web_server.name
        memory = libvirt_domain.web_server.memory
        vcpu   = libvirt_domain.web_server.vcpu
      }
      app = {
        name   = libvirt_domain.app_server.name
        memory = libvirt_domain.app_server.memory
        vcpu   = libvirt_domain.app_server.vcpu
      }
      db = {
        name   = libvirt_domain.db_server.name
        memory = libvirt_domain.db_server.memory
        vcpu   = libvirt_domain.db_server.vcpu
      }
    }
  }
}

output "vm_info" {
  description = "VM resource information"
  value = {
    web_server = "VM: ${libvirt_domain.web_server.name} (${libvirt_domain.web_server.memory}MB, ${libvirt_domain.web_server.vcpu} vCPU)"
    app_server = "VM: ${libvirt_domain.app_server.name} (${libvirt_domain.app_server.memory}MB, ${libvirt_domain.app_server.vcpu} vCPU)"
    db_server  = "VM: ${libvirt_domain.db_server.name} (${libvirt_domain.db_server.memory}MB, ${libvirt_domain.db_server.vcpu} vCPU)"
  }
}
