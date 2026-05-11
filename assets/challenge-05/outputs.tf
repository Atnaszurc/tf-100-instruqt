output "network_info" {
  description = "Network information"
  value = {
    name = libvirt_network.app_network.name
    id   = libvirt_network.app_network.id
  }
}

output "web_server" {
  description = "Web server information"
  value = {
    name   = libvirt_domain.web.name
    memory = libvirt_domain.web.memory
    vcpu   = libvirt_domain.web.vcpu
    id     = libvirt_domain.web.id
  }
}

output "app_server" {
  description = "Application server information"
  value = {
    name   = libvirt_domain.app.name
    memory = libvirt_domain.app.memory
    vcpu   = libvirt_domain.app.vcpu
    id     = libvirt_domain.app.id
  }
}

output "db_server" {
  description = "Database server information"
  value = {
    name   = libvirt_domain.db.name
    memory = libvirt_domain.db.memory
    vcpu   = libvirt_domain.db.vcpu
    id     = libvirt_domain.db.id
  }
}

output "environment" {
  description = "Current environment"
  value       = var.environment
}
