data "http" "host_ip" {
  url = "https://ifconfig.me"
}

data "azurerm_subscription" "current" {
}

data "azurerm_client_config" "current" {
}
