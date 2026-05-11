locals {
  # Naming convention
  name_prefix = "${var.environment}-${var.project_name}"

  # Get specs for current environment
  vm_memory = var.vm_specs[var.environment].memory
  vm_vcpu   = var.vm_specs[var.environment].vcpu

  # Common tags
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
      CreatedAt   = formatdate("YYYY-MM-DD", timestamp())
    }
  )

  # Generate VM configurations using for expression
  vm_configs = {
    for idx in range(var.vm_count) :
    "vm-${idx}" => {
      name      = "${local.name_prefix}-vm-${idx}"
      memory    = local.vm_memory
      vcpu      = local.vm_vcpu
      disk_size = 10737418240
    }
  }

  # Tag string for metadata
  tag_string = join(",", [for k, v in local.common_tags : "${k}=${v}"])
}
