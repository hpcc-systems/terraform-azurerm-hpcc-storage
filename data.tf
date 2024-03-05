data "http" "host_ip" {
  url = "https://api.ipify.org"
}

data "azurerm_subscription" "current" {
}

data "azurerm_client_config" "current" {
}
