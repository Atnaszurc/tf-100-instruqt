---
slug: infrastructure-resources
id: szxc5nuwgxgq
type: challenge
title: 'Challenge 3: Infrastructure Resources'
teaser: Build complete infrastructure with networks, storage, and virtual machines
notes:
- type: text
  contents: "# Challenge 3: Infrastructure Resources\n\nIn this challenge, you'll
    build a complete infrastructure stack including:\n\n- **Networks**: Virtual networks
    with proper addressing\n- **Storage**: Volumes and storage pools\n- **Virtual
    Machines**: Complete VMs with networking and storage\n- **Cloud-Init**: Automated
    VM configuration\n- **Dependencies**: Managing resource relationships\n\nLet's
    build real infrastructure! \U0001F3D7️\n"
tabs:
- id: tbjuwaryuc7y
  title: Terminal
  type: terminal
  hostname: workstation
- id: 7qb4iwcve5ap
  title: Code Editor
  type: code
  hostname: workstation
  path: /root/terraform-lab
difficulty: basic
timelimit: 7200
enhanced_loading: null
---

> **📝 Note on Code Examples**: This assignment contains simplified code examples for teaching purposes. The working solution in `/root/terraform-lab-solutions/challenge-03` uses libvirt provider 0.9+ syntax. When copying code, refer to the solution directory for production-ready examples.

# Challenge 3: Infrastructure Resources

## 🎯 Learning Objectives

By the end of this challenge, you will be able to:

1. **Create virtual networks** with proper DHCP and DNS configuration
2. **Manage storage resources** including pools and volumes
3. **Build complete VMs** with networking, storage, and configuration
4. **Use cloud-init** for automated VM setup
5. **Manage resource dependencies** explicitly and implicitly
6. **Implement proper resource lifecycle** management
7. **Use data sources** to reference existing resources

**Estimated Time**: 2 hours

---

## 📚 Why This Matters

### Real-World Scenario

You're tasked with deploying a web application infrastructure that includes:

- A private network for backend services
- Multiple VMs with different roles (web, database, cache)
- Proper storage allocation for each VM
- Automated configuration on first boot
- Security isolation between components

**Without proper infrastructure design**, you'd face:
- Network connectivity issues
- Storage conflicts and data loss
- Manual configuration overhead
- Security vulnerabilities
- Difficult troubleshooting

**With Terraform infrastructure resources**, you can:

✅ Define complete infrastructure as code
✅ Ensure proper resource dependencies
✅ Automate VM configuration with cloud-init
✅ Maintain consistent networking and storage
✅ Scale infrastructure reliably

---

## 🔍 Core Concepts

### 1. Virtual Networks

Networks provide connectivity between VMs and external systems:

```hcl
# Create a custom network
resource "libvirt_network" "app_network" {
  name      = "app-network"
  mode      = "nat"
  domain    = "app.local"
  addresses = ["10.17.3.0/24"]

  dhcp {
    enabled = true
  }

  dns {
    enabled    = true
    local_only = false
  }

  autostart = true
}
```

**Network Modes**:
- **NAT**: VMs can access external networks, external can't reach VMs directly
- **Bridge**: VMs appear on same network as host
- **Isolated**: VMs can only communicate with each other
- **Route**: VMs have routable IPs but no NAT

**Key Attributes**:
- `addresses`: CIDR blocks for the network
- `dhcp`: Automatic IP assignment
- `dns`: Name resolution within the network
- `autostart`: Start network when libvirt starts

### 2. Storage Pools and Volumes

Storage pools organize volumes, volumes provide disk space for VMs:

```hcl
# Storage pool (optional - default pool usually exists)
resource "libvirt_pool" "app_pool" {
  name = "app-pool"
  type = "dir"
  path = "/var/lib/libvirt/images/app-pool"
}

# Base image volume
resource "libvirt_volume" "base_image" {
  name   = "ubuntu-base.qcow2"
  pool   = libvirt_pool.app_pool.name
  source = "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"
  format = "qcow2"
}

# VM-specific volume (based on base image)
resource "libvirt_volume" "vm_disk" {
  name           = "vm-disk.qcow2"
  pool           = libvirt_pool.app_pool.name
  base_volume_id = libvirt_volume.base_image.id
  size           = 21474836480  # 20GB
  format         = "qcow2"
}
```

**Volume Types**:
- **Base volumes**: Downloaded images or templates
- **Derived volumes**: Created from base volumes (copy-on-write)
- **Empty volumes**: Blank disks for data storage

**Best Practices**:
- Use base volumes for OS images
- Create derived volumes for each VM
- Separate OS and data volumes
- Use appropriate formats (qcow2 for flexibility, raw for performance)

### 3. Cloud-Init Configuration

Cloud-init automates VM initialization:

```hcl
# Cloud-init configuration
data "template_file" "user_data" {
  template = file("${path.module}/cloud-init.yaml")

  vars = {
    hostname = "web-server"
    ssh_key  = file("~/.ssh/id_rsa.pub")
  }
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name      = "commoninit.iso"
  pool      = "default"
  user_data = data.template_file.user_data.rendered
}
```

**Cloud-Init YAML Example**:
```yaml
#cloud-config
hostname: ${hostname}
fqdn: ${hostname}.local
manage_etc_hosts: true

users:
  - name: ubuntu
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - ${ssh_key}

packages:
  - nginx
  - curl
  - vim

runcmd:
  - systemctl enable nginx
  - systemctl start nginx
  - echo "Hello from Terraform!" > /var/www/html/index.html
```

**Cloud-Init Capabilities**:
- Set hostname and network configuration
- Create users and SSH keys
- Install packages
- Run commands on first boot
- Configure services
- Write files

### 4. Complete VM Configuration

Bringing it all together:

```hcl
resource "libvirt_domain" "web_server" {
  name   = "web-server"
  memory = 2048
  vcpu   = 2

  # Cloud-init
  cloudinit = libvirt_cloudinit_disk.commoninit.id

  # Network interface
  network_interface {
    network_id     = libvirt_network.app_network.id
    hostname       = "web-server"
    wait_for_lease = true
  }

  # Boot disk
  disk {
    volume_id = libvirt_volume.vm_disk.id
  }

  # Console access
  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  # Graphics (for VNC/SPICE access)
  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }

  # Lifecycle management
  lifecycle {
    create_before_destroy = false
    prevent_destroy       = false
  }
}
```

### 5. Resource Dependencies

Terraform automatically handles dependencies, but you can make them explicit:

```hcl
# Implicit dependency (Terraform detects automatically)
resource "libvirt_domain" "vm" {
  name = "my-vm"

  disk {
    volume_id = libvirt_volume.disk.id  # Implicit dependency
  }
}

# Explicit dependency (when needed)
resource "libvirt_domain" "vm" {
  name = "my-vm"

  depends_on = [
    libvirt_network.app_network,
    libvirt_volume.disk
  ]
}
```

**Dependency Types**:
- **Implicit**: Terraform detects from resource references
- **Explicit**: Defined with `depends_on`
- **Data dependencies**: Data sources depend on resources

### 6. Data Sources

Data sources read existing infrastructure:

```hcl
# Reference existing network
data "libvirt_network" "default" {
  name = "default"
}

# Use in resource
resource "libvirt_domain" "vm" {
  name = "my-vm"

  network_interface {
    network_id = data.libvirt_network.default.id
  }
}
```

**Common Data Sources**:
- `libvirt_network`: Existing networks
- `libvirt_pool`: Existing storage pools
- `template_file`: File templates with variables
- `external`: Run external programs for data

---

## 🔧 Hands-On Lab

### Lab Overview

You'll create a complete 3-tier application infrastructure:

1. **Network Layer**: Custom network with DHCP/DNS
2. **Storage Layer**: Base image and VM-specific volumes
3. **Compute Layer**: Web, app, and database VMs
4. **Configuration Layer**: Cloud-init for automated setup

### Step 1: Create Network Configuration

Create `network.tf`:

```bash
cat > network.tf << 'EOF'
# Custom application network
resource "libvirt_network" "app_network" {
  name      = "app-network"
  mode      = "nat"
  domain    = "app.local"
  addresses = ["10.17.3.0/24"]

  dhcp {
    enabled = true
  }

  dns {
    enabled    = true
    local_only = false
  }

  autostart = true
}

# Output network information
output "network_info" {
  description = "Network configuration details"
  value = {
    name      = libvirt_network.app_network.name
    addresses = libvirt_network.app_network.addresses
    bridge    = libvirt_network.app_network.bridge
  }
}
EOF
```

### Step 2: Create Storage Configuration

Create `storage.tf`:

```bash
cat > storage.tf << 'EOF'
# Base Ubuntu image
resource "libvirt_volume" "ubuntu_base" {
  name   = "ubuntu-22.04-base.qcow2"
  pool   = "default"
  source = "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"
  format = "qcow2"
}

# Web server disk
resource "libvirt_volume" "web_disk" {
  name           = "web-server-disk.qcow2"
  pool           = "default"
  base_volume_id = libvirt_volume.ubuntu_base.id
  size           = 21474836480  # 20GB
  format         = "qcow2"
}

# App server disk
resource "libvirt_volume" "app_disk" {
  name           = "app-server-disk.qcow2"
  pool           = "default"
  base_volume_id = libvirt_volume.ubuntu_base.id
  size           = 21474836480  # 20GB
  format         = "qcow2"
}

# Database server disk
resource "libvirt_volume" "db_disk" {
  name           = "db-server-disk.qcow2"
  pool           = "default"
  base_volume_id = libvirt_volume.ubuntu_base.id
  size           = 32212254720  # 30GB (larger for database)
  format         = "qcow2"
}

# Output storage information
output "storage_info" {
  description = "Storage configuration details"
  value = {
    base_image = libvirt_volume.ubuntu_base.name
    volumes = {
      web = libvirt_volume.web_disk.name
      app = libvirt_volume.app_disk.name
      db  = libvirt_volume.db_disk.name
    }
  }
}
EOF
```

### Step 3: Create Cloud-Init Configuration

Create `cloud-init-web.yaml`:

```bash
cat > cloud-init-web.yaml << 'EOF'
#cloud-config
hostname: web-server
fqdn: web-server.app.local
manage_etc_hosts: true

users:
  - name: ubuntu
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: false
    passwd: $6$rounds=4096$saltsaltsal$L/jSKXLnJvr7DJvKvGKKKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvKvK

packages:
  - nginx
  - curl
  - htop
  - vim

write_files:
  - path: /var/www/html/index.html
    content: |
      <!DOCTYPE html>
      <html>
      <head>
          <title>Web Server - Terraform Lab</title>
          <style>
              body { font-family: Arial, sans-serif; margin: 40px; }
              .header { color: #2c3e50; }
              .info { background: #ecf0f1; padding: 20px; border-radius: 5px; }
          </style>
      </head>
      <body>
          <h1 class="header">🌐 Web Server</h1>
          <div class="info">
              <p><strong>Hostname:</strong> web-server.app.local</p>
              <p><strong>Role:</strong> Frontend Web Server</p>
              <p><strong>Deployed by:</strong> Terraform + Cloud-Init</p>
              <p><strong>Status:</strong> ✅ Online</p>
          </div>
      </body>
      </html>
    permissions: '0644'

runcmd:
  - systemctl enable nginx
  - systemctl start nginx
  - ufw allow 'Nginx Full'
  - echo "Web server setup complete" > /var/log/terraform-setup.log
EOF
```

Create `cloud-init-app.yaml`:

```bash
cat > cloud-init-app.yaml << 'EOF'
#cloud-config
hostname: app-server
fqdn: app-server.app.local
manage_etc_hosts: true

users:
  - name: ubuntu
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: false

packages:
  - python3
  - python3-pip
  - curl
  - htop
  - vim

write_files:
  - path: /opt/app/server.py
    content: |
      #!/usr/bin/env python3
      from http.server import HTTPServer, BaseHTTPRequestHandler
      import json
      import socket

      class AppHandler(BaseHTTPRequestHandler):
          def do_GET(self):
              self.send_response(200)
              self.send_header('Content-type', 'application/json')
              self.end_headers()

              response = {
                  "service": "app-server",
                  "hostname": socket.gethostname(),
                  "status": "healthy",
                  "message": "Application server running via Terraform!"
              }

              self.wfile.write(json.dumps(response, indent=2).encode())

      if __name__ == '__main__':
          server = HTTPServer(('0.0.0.0', 8080), AppHandler)
          print("App server starting on port 8080...")
          server.serve_forever()
    permissions: '0755'

  - path: /etc/systemd/system/app-server.service
    content: |
      [Unit]
      Description=Application Server
      After=network.target

      [Service]
      Type=simple
      User=ubuntu
      WorkingDirectory=/opt/app
      ExecStart=/usr/bin/python3 /opt/app/server.py
      Restart=always

      [Install]
      WantedBy=multi-user.target
    permissions: '0644'

runcmd:
  - mkdir -p /opt/app
  - systemctl daemon-reload
  - systemctl enable app-server
  - systemctl start app-server
  - echo "App server setup complete" > /var/log/terraform-setup.log
EOF
```

Create `cloud-init-db.yaml`:

```bash
cat > cloud-init-db.yaml << 'EOF'
#cloud-config
hostname: db-server
fqdn: db-server.app.local
manage_etc_hosts: true

users:
  - name: ubuntu
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: false

packages:
  - sqlite3
  - curl
  - htop
  - vim

write_files:
  - path: /opt/database/init.sql
    content: |
      CREATE TABLE IF NOT EXISTS users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT UNIQUE NOT NULL,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      );

      INSERT INTO users (name, email) VALUES
          ('Alice Johnson', 'alice@example.com'),
          ('Bob Smith', 'bob@example.com'),
          ('Carol Davis', 'carol@example.com');
    permissions: '0644'

runcmd:
  - mkdir -p /opt/database
  - sqlite3 /opt/database/app.db < /opt/database/init.sql
  - chown -R ubuntu:ubuntu /opt/database
  - echo "Database server setup complete" > /var/log/terraform-setup.log
EOF
```

### Step 4: Create Cloud-Init Disks

Create `cloud-init.tf`:

```bash
cat > cloud-init.tf << 'EOF'
# Cloud-init disk for web server
resource "libvirt_cloudinit_disk" "web_init" {
  name      = "web-init.iso"
  pool      = "default"
  user_data = file("${path.module}/cloud-init-web.yaml")
}

# Cloud-init disk for app server
resource "libvirt_cloudinit_disk" "app_init" {
  name      = "app-init.iso"
  pool      = "default"
  user_data = file("${path.module}/cloud-init-app.yaml")
}

# Cloud-init disk for database server
resource "libvirt_cloudinit_disk" "db_init" {
  name      = "db-init.iso"
  pool      = "default"
  user_data = file("${path.module}/cloud-init-db.yaml")
}
EOF
```

### Step 5: Create Virtual Machines

Create `vms.tf`:

```bash
cat > vms.tf << 'EOF'
# Web server VM
resource "libvirt_domain" "web_server" {
  name   = "web-server"
  memory = 1024
  vcpu   = 1

  cloudinit = libvirt_cloudinit_disk.web_init.id

  network_interface {
    network_id     = libvirt_network.app_network.id
    hostname       = "web-server"
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.web_disk.id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

# Application server VM
resource "libvirt_domain" "app_server" {
  name   = "app-server"
  memory = 1024
  vcpu   = 1

  cloudinit = libvirt_cloudinit_disk.app_init.id

  network_interface {
    network_id     = libvirt_network.app_network.id
    hostname       = "app-server"
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.app_disk.id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

# Database server VM
resource "libvirt_domain" "db_server" {
  name   = "db-server"
  memory = 2048
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.db_init.id

  network_interface {
    network_id     = libvirt_network.app_network.id
    hostname       = "db-server"
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.db_disk.id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}
EOF
```

### Step 6: Create Main Configuration

Create `main.tf`:

```bash
cat > main.tf << 'EOF'
terraform {
  required_version = ">= 1.0"

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.7"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}
EOF
```

### Step 7: Create Outputs

Create `outputs.tf`:

```bash
cat > outputs.tf << 'EOF'
# VM IP addresses
output "vm_ips" {
  description = "IP addresses of all VMs"
  value = {
    web_server = libvirt_domain.web_server.network_interface[0].addresses[0]
    app_server = libvirt_domain.app_server.network_interface[0].addresses[0]
    db_server  = libvirt_domain.db_server.network_interface[0].addresses[0]
  }
}

# Infrastructure summary
output "infrastructure_summary" {
  description = "Complete infrastructure overview"
  value = {
    network = {
      name    = libvirt_network.app_network.name
      cidr    = libvirt_network.app_network.addresses[0]
      bridge  = libvirt_network.app_network.bridge
    }
    vms = {
      web = {
        name   = libvirt_domain.web_server.name
        memory = libvirt_domain.web_server.memory
        vcpu   = libvirt_domain.web_server.vcpu
        ip     = libvirt_domain.web_server.network_interface[0].addresses[0]
      }
      app = {
        name   = libvirt_domain.app_server.name
        memory = libvirt_domain.app_server.memory
        vcpu   = libvirt_domain.app_server.vcpu
        ip     = libvirt_domain.app_server.network_interface[0].addresses[0]
      }
      db = {
        name   = libvirt_domain.db_server.name
        memory = libvirt_domain.db_server.memory
        vcpu   = libvirt_domain.db_server.vcpu
        ip     = libvirt_domain.db_server.network_interface[0].addresses[0]
      }
    }
  }
}

# Service URLs
output "service_urls" {
  description = "URLs to access services"
  value = {
    web_server = "http://${libvirt_domain.web_server.network_interface[0].addresses[0]}"
    app_server = "http://${libvirt_domain.app_server.network_interface[0].addresses[0]}:8080"
  }
}
EOF
```

### Step 8: Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan deployment
terraform plan

# Apply configuration
terraform apply -auto-approve
```

### Step 9: Test Infrastructure

```bash
# Wait for VMs to boot (2-3 minutes)
sleep 180

# Get VM IPs
terraform output vm_ips

# Test web server (replace IP with actual)
WEB_IP=$(terraform output -json vm_ips | jq -r '.web_server')
curl http://$WEB_IP

# Test app server (replace IP with actual)
APP_IP=$(terraform output -json vm_ips | jq -r '.app_server')
curl http://$APP_IP:8080

# Check VM status
virsh list --all

# Check network
virsh net-list --all
```

### Step 10: Explore Infrastructure

```bash
# View complete infrastructure
terraform output infrastructure_summary

# Check resource dependencies
terraform graph | dot -Tpng > infrastructure.png

# Connect to VMs (if needed)
# virsh console web-server
# (Use Ctrl+] to exit console)
```

### Step 11: Clean Up

```bash
terraform destroy -auto-approve
```

---

## 🧪 Knowledge Check

Test your understanding with these questions:

<details>
<summary><strong>Question 1:</strong> What's the difference between implicit and explicit dependencies in Terraform?</summary>

**Answer:**

**Implicit Dependencies:**
- Terraform automatically detects when one resource references another
- Created by using resource attributes in other resources
- Example: `volume_id = libvirt_volume.disk.id`
- Terraform builds dependency graph automatically

**Explicit Dependencies:**
- Manually specified using `depends_on`
- Used when dependency isn't obvious from resource references
- Example: When a resource needs another to exist but doesn't reference its attributes
- Useful for ordering resources that don't have direct attribute relationships

**Example:**
```hcl
# Implicit - Terraform detects dependency
resource "libvirt_domain" "vm" {
  disk {
    volume_id = libvirt_volume.disk.id  # Implicit dependency
  }
}

# Explicit - Manual dependency specification
resource "libvirt_domain" "vm" {
  depends_on = [libvirt_network.app_network]  # Explicit dependency
}
```

**Best Practice:** Prefer implicit dependencies when possible, use explicit only when necessary.
</details>

<details>
<summary><strong>Question 2:</strong> Why use base volumes and derived volumes instead of creating separate volumes for each VM?</summary>

**Answer:**

**Benefits of Base + Derived Volume Pattern:**

1. **Storage Efficiency:**
   - Base volume stored once
   - Derived volumes only store differences (copy-on-write)
   - Saves significant disk space

2. **Faster Provisioning:**
   - No need to download image for each VM
   - Quick volume creation from existing base

3. **Consistency:**
   - All VMs start from same base image
   - Ensures identical starting configuration

4. **Updates:**
   - Update base image once
   - Recreate derived volumes to get updates

**Example:**
```hcl
# Base image (downloaded once)
resource "libvirt_volume" "ubuntu_base" {
  name   = "ubuntu-base.qcow2"
  source = "https://cloud-images.ubuntu.com/..."
}

# Derived volumes (copy-on-write)
resource "libvirt_volume" "vm1_disk" {
  base_volume_id = libvirt_volume.ubuntu_base.id
  size           = 21474836480
}
```

**Alternative (inefficient):**
```hcl
# Don't do this - downloads image for each VM
resource "libvirt_volume" "vm1_disk" {
  source = "https://cloud-images.ubuntu.com/..."  # Downloaded again!
}
```
</details>

<details>
<summary><strong>Question 3:</strong> What are the key components of a cloud-init configuration?</summary>

**Answer:**

**Essential Cloud-Init Sections:**

1. **System Configuration:**
   ```yaml
   hostname: web-server
   fqdn: web-server.example.com
   manage_etc_hosts: true
   ```

2. **User Management:**
   ```yaml
   users:
     - name: ubuntu
       sudo: ALL=(ALL) NOPASSWD:ALL
       ssh_authorized_keys:
         - ssh-rsa AAAAB3...
   ```

3. **Package Installation:**
   ```yaml
   packages:
     - nginx
     - curl
     - vim
   ```

4. **File Creation:**
   ```yaml
   write_files:
     - path: /etc/nginx/sites-available/default
       content: |
         server {
           listen 80;
           root /var/www/html;
         }
   ```

5. **Command Execution:**
   ```yaml
   runcmd:
     - systemctl enable nginx
     - systemctl start nginx
   ```

**Execution Order:**
1. System configuration
2. Users and SSH keys
3. Package installation
4. File writing
5. Command execution

**Best Practices:**
- Use `write_files` for configuration files
- Use `runcmd` for service management
- Test cloud-init configs before deployment
- Keep configurations idempotent
</details>

<details>
<summary><strong>Question 4:</strong> How do you troubleshoot VM connectivity issues?</summary>

**Answer:**

**Systematic Troubleshooting Approach:**

1. **Check VM Status:**
   ```bash
   virsh list --all
   virsh dominfo vm-name
   ```

2. **Verify Network Configuration:**
   ```bash
   virsh net-list --all
   virsh net-info network-name
   ```

3. **Check IP Assignment:**
   ```bash
   virsh net-dhcp-leases network-name
   terraform output vm_ips
   ```

4. **Test Network Connectivity:**
   ```bash
   # From host to VM
   ping VM_IP

   # From VM to external (via console)
   virsh console vm-name
   ping 8.8.8.8
   ```

5. **Check Cloud-Init Status:**
   ```bash
   # Via console
   cloud-init status
   journalctl -u cloud-init
   ```

6. **Verify Services:**
   ```bash
   # Check if services started
   systemctl status nginx
   netstat -tlnp
   ```

**Common Issues:**
- Network not started: `virsh net-start network-name`
- DHCP not working: Check network DHCP configuration
- Cloud-init failed: Check YAML syntax and logs
- Firewall blocking: Check iptables/ufw rules
- Wrong network mode: Verify NAT vs bridge configuration

**Debug Commands:**
```bash
# Network debugging
virsh net-dumpxml network-name
ip route show
iptables -L -n

# VM debugging
virsh dumpxml vm-name
virsh console vm-name
```
</details>

<details>
<summary><strong>Question 5:</strong> What's the difference between NAT and bridge network modes?</summary>

**Answer:**

**NAT Mode:**
- VMs get private IPs (e.g., 192.168.122.x)
- VMs can access external networks via host
- External networks cannot directly reach VMs
- Host acts as router/firewall
- Good for development and testing

**Bridge Mode:**
- VMs appear on same network as host
- VMs get IPs from external DHCP (if available)
- External networks can directly reach VMs
- No NAT translation
- Good for production-like environments

**Comparison:**

| Aspect | NAT | Bridge |
|--------|-----|--------|
| VM IP Range | Private (192.168.x.x) | Same as host network |
| External Access | Via host NAT | Direct |
| Inbound Connections | Blocked by default | Allowed |
| Network Isolation | High | Low |
| Setup Complexity | Simple | May need network config |

**Use Cases:**

**NAT Mode:**
```hcl
resource "libvirt_network" "nat_network" {
  name      = "nat-network"
  mode      = "nat"          # NAT mode
  addresses = ["10.17.3.0/24"]
}
```
- Development environments
- Testing isolated applications
- When you don't want VMs accessible externally

**Bridge Mode:**
```hcl
resource "libvirt_network" "bridge_network" {
  name   = "bridge-network"
  mode   = "bridge"          # Bridge mode
  bridge = "br0"             # Existing bridge
}
```
- Production environments
- When VMs need external accessibility
- Integration with existing networks
</details>

---

## 🔍 Troubleshooting Guide

### Issue: "Network not found"

**Error:**
```
Error: virsh command error: error: Network not found: no network with matching name 'app-network'
```

**Solution:**
Check if network was created and is active:

```bash
# List all networks
virsh net-list --all

# Start network if stopped
virsh net-start app-network

# Check Terraform state
terraform state list | grep network
```

### Issue: "Volume download fails"

**Error:**
```
Error: error creating libvirt volume: virsh command error: error: Failed to create vol ubuntu-base.qcow2
```

**Solution:**
Check network connectivity and disk space:

```bash
# Check disk space
df -h /var/lib/libvirt/images

# Test URL manually
curl -I https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img

# Use local file if needed
resource "libvirt_volume" "base" {
  name   = "base.qcow2"
  source = "/path/to/local/image.qcow2"
}
```

### Issue: "VM won't start"

**Error:**
```
Error: error creating libvirt domain: virsh command error: error: Failed to create domain from /tmp/...
```

**Solution:**
Check VM configuration and resources:

```bash
# Check available memory
free -h

# Check if volumes exist
virsh vol-list default

# Verify cloud-init disk
ls -la /var/lib/libvirt/images/*.iso

# Check libvirt logs
journalctl -u libvirtd
```

### Issue: "Cloud-init not working"

**Error:**
VM starts but cloud-init configuration not applied.

**Solution:**
Debug cloud-init configuration:

```bash
# Connect to VM console
virsh console vm-name

# Check cloud-init status
cloud-init status --long

# View cloud-init logs
journalctl -u cloud-init

# Validate YAML syntax locally
python3 -c "import yaml; yaml.safe_load(open('cloud-init-web.yaml'))"
```

### Issue: "Cannot connect to VM"

**Error:**
VM is running but not accessible via network.

**Solution:**
Check network configuration:

```bash
# Check VM IP assignment
virsh net-dhcp-leases app-network

# Verify network is active
virsh net-info app-network

# Test from host
ping VM_IP

# Check VM network config (via console)
ip addr show
ip route show
```

---

## 💡 Common Pitfalls

### 1. Forgetting Resource Dependencies

**Problem:**
```hcl
resource "libvirt_domain" "vm" {
  network_interface {
    network_name = "app-network"  # ❌ Network might not exist yet
  }
}
```

**Solution:**
```hcl
resource "libvirt_domain" "vm" {
  network_interface {
    network_id = libvirt_network.app_network.id  # ✅ Proper dependency
  }
}
```

### 2. Incorrect Volume Sizing

**Problem:**
```hcl
resource "libvirt_volume" "disk" {
  size = 20  # ❌ Too small - this is 20 bytes!
}
```

**Solution:**
```hcl
resource "libvirt_volume" "disk" {
  size = 21474836480  # ✅ 20GB in bytes
  # Or use calculation
  size = 20 * 1024 * 1024 * 1024
}
```

### 3. Invalid Cloud-Init YAML

**Problem:**
```yaml
#cloud-config
users:
  - name: ubuntu
  sudo: ALL=(ALL) NOPASSWD:ALL  # ❌ Wrong indentation
```

**Solution:**
```yaml
#cloud-config
users:
  - name: ubuntu
    sudo: ALL=(ALL) NOPASSWD:ALL  # ✅ Correct indentation
```

### 4. Network Address Conflicts

**Problem:**
```hcl
resource "libvirt_network" "net1" {
  addresses = ["192.168.1.0/24"]  # ❌ Might conflict with host
}
```

**Solution:**
```hcl
resource "libvirt_network" "net1" {
  addresses = ["10.17.3.0/24"]  # ✅ Use private range unlikely to conflict
}
```

### 5. Not Waiting for DHCP Leases

**Problem:**
```hcl
network_interface {
  network_id = libvirt_network.app_network.id
  # ❌ Missing wait_for_lease
}
```

**Solution:**
```hcl
network_interface {
  network_id     = libvirt_network.app_network.id
  wait_for_lease = true  # ✅ Wait for IP assignment
}
```

---

## 🎓 Key Takeaways

1. **Networks provide connectivity** - Define custom networks for proper isolation and addressing
2. **Storage hierarchy matters** - Use base volumes + derived volumes for efficiency
3. **Cloud-init automates configuration** - Eliminate manual VM setup with cloud-init
4. **Dependencies ensure order** - Terraform handles most dependencies automatically
5. **Resource lifecycle is important** - Understand creation, update, and destruction patterns
6. **Testing is crucial** - Always verify infrastructure works as expected
7. **Troubleshooting is systematic** - Follow logical steps to diagnose issues

---

## 📚 Additional Resources

- [Libvirt Provider Documentation](https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs)
- [Cloud-Init Documentation](https://cloud-init.readthedocs.io/)
- [KVM/QEMU Networking Guide](https://wiki.libvirt.org/page/Networking)
- [Terraform Resource Dependencies](https://www.terraform.io/language/resources/behavior#resource-dependencies)

---

## ✅ Challenge Complete!

You've built a complete infrastructure stack! You can now:

✅ Create virtual networks with proper configuration
✅ Manage storage pools and volumes efficiently
✅ Deploy VMs with automated configuration
✅ Use cloud-init for VM initialization
✅ Handle resource dependencies correctly
✅ Troubleshoot infrastructure issues
✅ Build production-ready infrastructure patterns

**Next Challenge**: State Management & CLI - Master Terraform's state system and advanced CLI features! 🚀