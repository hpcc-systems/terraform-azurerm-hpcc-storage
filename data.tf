data "http" "host_ip" {
  count = var.use_authorized_ip_ranges_only ? 0 : 1
  
  url = "https://api.ipify.org"
}

data "azurerm_subscription" "current" {
}

data "azurerm_client_config" "current" {
}
