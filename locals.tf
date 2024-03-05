locals {
  names = var.disable_naming_conventions ? merge(
    {
      business_unit     = var.metadata.business_unit
      environment       = var.metadata.environment
      location          = var.metadata.location
      market            = var.metadata.market
      subscription_type = var.metadata.subscription_type
    },
    var.metadata.product_group != "" ? { product_group = var.metadata.product_group } : {},
    var.metadata.product_name != "" ? { product_name = var.metadata.product_name } : {},
    var.metadata.resource_group_type != "" ? { resource_group_type = var.metadata.resource_group_type } : {}
  ) : module.metadata.names

  tags = merge(var.metadata.additional_tags, { "owner" = var.owner.name, "owner_email" = var.owner.email })

  location = var.metadata.location

  resource_groups = {
    storage_accounts = {
      tags = { "enclosed resource" = "OSS storage accounts" }
    }
  }

  azure_files_pv_protocol = "nfs"

  planes = flatten([
    for k, v in var.storage_accounts :
    [
      for x, y in v.planes : {
        "container_name" : "${y.plane_name}"
        "plane_name" : "${y.plane_name}"
        "category" : "${y.category}"
        "path" : "${y.sub_path}"
        "size" : "${y.size}"
        "storage_account_name" : v.storage_type == "azurefiles" ? "${v.storage_account_name_prefix}${random_string.random.result}af" : "${v.storage_account_name_prefix}${random_string.random.result}blob"
        "storage_account_name_prefix" : v.storage_account_name_prefix
        "resource_group" : "${module.resource_groups["storage_accounts"].name}"
        "storage_type" : "${v.storage_type}"
        "protocol" : v.storage_type == "azurefiles" ? "${upper(y.protocol)}" : null
        "access_tier" : "${v.access_tier}"
        "account_kind" : "${v.account_kind}"
        "account_tier" : "${v.account_tier}"
        "replication_type" : "${v.replication_type}"
        "authorized_ip_ranges" : "${tomap(merge(var.authorized_ip_ranges, { host_ip = data.http.host_ip.response_body }))}"
        "subnet_ids" : "${var.subnet_ids}"
        "file_share_retention_days" : v.storage_type == "azurefiles" ? "${v.file_share_retention_days}" : null
      }
    ]
  ])

  azurefile_storage_accounts_args = {
    for k, v in var.storage_accounts : k => merge({ storage_account_name = "${v.storage_account_name_prefix}${random_string.random.result}af" }, v, { "resource_group_name" = module.resource_groups["storage_accounts"].name }) if v.storage_type == "azurefiles"
  }

  blob_storage_accounts_args = {
    for k, v in var.storage_accounts : k => merge({ storage_account_name = "${v.storage_account_name_prefix}${random_string.random.result}blob" }, v, { "resource_group_name" = module.resource_groups["storage_accounts"].name }) if v.storage_type == "blobnfs"
  }

  azurefile_planes = {
    for k, v in local.planes : k => v if v.storage_type == "azurefiles"
  }

  blob_planes = {
    for k, v in local.planes : k => v if v.storage_type == "blobnfs"
  }

  azurefile_storage_accounts_attrs = {
    for k, v in azurerm_storage_account.azurefiles : k => {
      storage_account_name     = v.name
      resource_group_name      = v.resource_group_name
      id                       = v.id
      account_replication_type = v.account_replication_type
      account_tier             = v.account_tier
      primary_access_key       = v.primary_access_key
      primary_location         = v.primary_location
    }
  }

  blob_storage_accounts_attrs = {
    for k, v in azurerm_storage_account.blobnfs : k => {
      storage_account_name     = v.name
      resource_group_name      = v.resource_group_name
      id                       = v.id
      account_replication_type = v.account_replication_type
      account_tier             = v.account_tier
      primary_access_key       = v.primary_access_key
      primary_location         = v.primary_location
    }
  }
}
