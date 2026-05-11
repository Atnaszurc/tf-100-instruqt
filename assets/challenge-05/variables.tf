variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be dev or prod."
  }
}

variable "project_name" {
  description = "Project identifier"
  type        = string
  default     = "webapp"
}

variable "network_cidr" {
  description = "Network CIDR block"
  type        = string
  default     = "10.20.0.0/24"
}

variable "vm_specs" {
  description = "VM specifications per environment"
  type = map(object({
    web = object({
      memory    = number
      vcpu      = number
      disk_size = number
    })
    app = object({
      memory    = number
      vcpu      = number
      disk_size = number
    })
    db = object({
      memory    = number
      vcpu      = number
      disk_size = number
    })
  }))

  default = {
    dev = {
      web = {
        memory    = 1024
        vcpu      = 1
        disk_size = 16106127360
      }
      app = {
        memory    = 1024
        vcpu      = 1
        disk_size = 16106127360
      }
      db = {
        memory    = 1024
        vcpu      = 1
        disk_size = 16106127360
      }
    }
    prod = {
      web = {
        memory    = 2048
        vcpu      = 2
        disk_size = 26843545600
      }
      app = {
        memory    = 2048
        vcpu      = 2
        disk_size = 26843545600
      }
      db = {
        memory    = 4096
        vcpu      = 2
        disk_size = 26843545600
      }
    }
  }
}
