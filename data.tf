data "http" "host_ip" {
  url = "https://ipconfig.org"
}

data "azurerm_subscription" "current" {
}

data "azurerm_client_config" "current" {
}
