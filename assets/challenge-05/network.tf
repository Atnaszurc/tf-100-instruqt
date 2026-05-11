# Network configuration
resource "libvirt_network" "app_network" {
  name      = "${var.environment}-network"
  autostart = true
}
