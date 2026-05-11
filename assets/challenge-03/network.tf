resource "libvirt_network" "app_network" {
  name      = "app-network"
  autostart = true

  domain = {
    name = "app.local"
  }

  # Note: In libvirt provider 0.9.3, mode and addresses are not supported
  # Networks are automatically NAT-enabled with DHCP
}

output "network_info" {
  description = "Network configuration details"
  value = {
    name   = libvirt_network.app_network.name
    bridge = libvirt_network.app_network.bridge
  }
}
