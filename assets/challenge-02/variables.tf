variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "terraform-lab"
}

variable "vm_count" {
  description = "Number of VMs to create"
  type        = number
  default     = 2

  validation {
    condition     = var.vm_count > 0 && var.vm_count <= 5
    error_message = "VM count must be between 1 and 5."
  }
}

variable "vm_specs" {
  description = "VM specifications by environment"
  type = map(object({
    memory = number
    vcpu   = number
  }))
  default = {
    dev = {
      memory = 1024
      vcpu   = 1
    }
    staging = {
      memory = 2048
      vcpu   = 2
    }
    prod = {
      memory = 4096
      vcpu   = 4
    }
  }
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
