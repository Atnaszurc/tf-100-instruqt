# Local values for common configurations
locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "Skills Assessment"
  }

  vm_name_prefix = var.environment
}
