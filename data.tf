data "http" "host_ip" {
  count = var.use_authorized_ip_ranges_only ? 0 : 1
  url   = "http://ipv4.icanhazip.com"
}

data "azurerm_subscription" "current" {
}

data "azurerm_client_config" "current" {
}
