resource "azurerm_management_lock" "protect_azurefile_storage_accounts" {
  for_each = {
    for k, v in var.storage_accounts : k => v if v.storage_type == "azurefiles" && v.delete_protection
  }

  name       = "protect-storage-${azurerm_storage_account.azurefiles[each.key].name}"
  scope      = azurerm_storage_account.azurefiles[each.key].id
  lock_level = "CanNotDelete"
}

resource "azurerm_management_lock" "protect_blobnfs_storage_accounts" {
  for_each = {
    for k, v in var.storage_accounts : k => v if v.storage_type == "blobnfs" && v.delete_protection
  }

  name       = "protect-storage-${azurerm_storage_account.blobnfs[each.key].name}"
  scope      = azurerm_storage_account.blobnfs[each.key].id
  lock_level = "CanNotDelete"
}

resource "azurerm_storage_account" "azurefiles" {
  for_each = local.azurefile_storage_accounts

  name                = "hpcc${each.value.prefix_name}${random_string.random.result}af"
  resource_group_name = module.resource_groups["storage_accounts"].name
  location            = local.location
  tags                = local.tags

  access_tier                     = each.value.access_tier
  account_kind                    = each.value.account_kind
  account_tier                    = each.value.account_tier
  allow_nested_items_to_be_public = false
  min_tls_version                 = "TLS1_2"

  shared_access_key_enabled = true

  https_traffic_only_enabled = false
  account_replication_type  = each.value.replication_type

  network_rules {
    default_action             = "Deny"
    ip_rules                   = values(merge(each.value.authorized_ip_ranges, { host_ip = data.http.host_ip.response_body }))
    virtual_network_subnet_ids = values(each.value.subnet_ids)
    bypass                     = ["AzureServices"]
  }
  share_properties {
    retention_policy {
      days = each.value.file_share_retention_days
    }
  }
}

resource "azurerm_storage_account" "blobnfs" {
  for_each = local.blob_storage_accounts

  name                = "hpcc${each.value.prefix_name}${random_string.random.result}blob"
  resource_group_name = module.resource_groups["storage_accounts"].name
  location            = local.location
  tags                = local.tags

  access_tier                     = each.value.access_tier
  account_kind                    = each.value.account_kind
  account_tier                    = each.value.account_tier
  allow_nested_items_to_be_public = false
  is_hns_enabled                  = true
  min_tls_version                 = "TLS1_2"

  shared_access_key_enabled = true

  nfsv3_enabled             = true
  https_traffic_only_enabled = true
  account_replication_type  = each.value.replication_type


  network_rules {
    default_action             = "Deny"
    ip_rules                   = values(merge(each.value.authorized_ip_ranges, { host_ip = data.http.host_ip.response_body }))
    virtual_network_subnet_ids = values(each.value.subnet_ids)
    bypass                     = ["AzureServices"]
  }

  blob_properties {
    delete_retention_policy {
      days = each.value.blob_soft_delete_retention_days
    }
    container_delete_retention_policy {
      days = each.value.container_soft_delete_retention_days
    }
  }
}

resource "azurerm_storage_share" "azurefiles" {
  for_each = local.azurefile_planes

  name                 = each.value.container_name
  storage_account_id = azurerm_storage_account.azurefiles[each.key].id
  quota                = each.value.size
  enabled_protocol     = each.value.protocol
}

resource "azurerm_storage_container" "blobnfs" {
  for_each = local.blob_planes

  name                  = each.value.container_name
  storage_account_id  = azurerm_storage_account.blobnfs[each.value.key].id
  container_access_type = "private"
}
