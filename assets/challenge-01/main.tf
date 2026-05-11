# Example Solution for Challenge 1
# This is provided as a reference - try to complete the challenge yourself first!

terraform {
  required_version = ">= 1.14"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.7"
    }
  }
}

provider "local" {}

# Resource 1: Simple greeting file
resource "local_file" "hello" {
  content  = "Hello, Terraform! This is my first infrastructure as code."
  filename = "${path.module}/hello.txt"
}

# Resource 2: Training information with heredoc
resource "local_file" "info" {
  content  = <<-EOT
    Terraform Training
    ==================
    Course: TF-101
    Topic: Introduction to IaC & Terraform Basics
    
    This file was created by Terraform!
    Timestamp: ${timestamp()}
  EOT
  filename = "${path.module}/info.txt"
}

# Resource 3: Configuration file
resource "local_file" "config" {
  content  = <<-EOT
    # Application Configuration
    app_name = "terraform-training"
    version  = "1.0.0"
    environment = "development"
    
    # Features
    enable_logging = true
    enable_metrics = true
  EOT
  filename = "${path.module}/app-config.txt"
}

# Outputs
output "hello_file_id" {
  description = "ID of the hello.txt file"
  value       = local_file.hello.id
}

output "all_files" {
  description = "List of all created files"
  value = [
    local_file.hello.filename,
    local_file.info.filename,
    local_file.config.filename
  ]
}
