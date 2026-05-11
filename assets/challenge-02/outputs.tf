output "environment" {
  description = "Current environment"
  value       = var.environment
}

output "vm_names" {
  description = "Names of created VMs"
  value       = [for vm in libvirt_domain.vm : vm.name]
}

output "vm_details" {
  description = "Detailed VM information"
  value = {
    for k, vm in libvirt_domain.vm :
    k => {
      name   = vm.name
      memory = vm.memory
      vcpu   = vm.vcpu
      id     = vm.id
    }
  }
}

output "total_memory" {
  description = "Total memory allocated (MB)"
  value       = sum([for vm in libvirt_domain.vm : vm.memory])
}

output "total_vcpus" {
  description = "Total vCPUs allocated"
  value       = sum([for vm in libvirt_domain.vm : vm.vcpu])
}

output "resource_tags" {
  description = "Common resource tags"
  value       = local.common_tags
}
