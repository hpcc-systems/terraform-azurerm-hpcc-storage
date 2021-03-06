output "resource_group_name" {
  value = module.resource_group.name
}

output "subscription_id" {
  value = data.azurerm_subscription.current.subscription_id
}

output "storage_account_name" {
  value = azurerm_storage_account.storage_account.name
}

output "location" {
  value = module.resource_group.location
}
