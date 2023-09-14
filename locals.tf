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

  location = var.virtual_network.location

  resource_groups = {
    storage_accounts = {
      tags = { "enclosed resource" = "OSS storage accounts" }
    }
  }

  subnet_ids = {
    for k, v in var.virtual_network.subnet_ids : k => "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.virtual_network.resource_group_name}/providers/Microsoft.Network/virtualNetworks/${var.virtual_network.name}/subnets/${v}"
  }

  azure_files_pv_protocol = "nfs"

  planes = flatten([
    for k, v in var.storage_accounts :
    [
      for x, y in v.planes : {
        "container_name" : "${y.name}"
        "plane_name" : "${y.name}"
        "category" : "${y.category}"
        "path" : "${y.sub_path}"
        "size" : "${y.size}"
        "storage_account" : v.storage_type == "azurefiles" ? "${azurerm_storage_account.azurefiles[v.prefix_name].name}" : "${azurerm_storage_account.blobnfs[v.prefix_name].name}"
        "resource_group" : "${module.resource_groups["storage_accounts"].name}"
        "storage_type" : "${v.storage_type}"
        "protocol" : v.storage_type == "azurefiles" ? "${upper(y.protocol)}" : null
        "access_tier" : "${v.access_tier}"
        "account_kind" : "${v.account_kind}"
        "account_tier" : "${v.account_tier}"
        "replication_type" : "${v.replication_type}"
        "authorized_ip_ranges" : "${merge(v.authorized_ip_ranges, { host_ip = data.http.host_ip.response_body })}"
        "subnet_ids" : "${v.subnet_ids}"
        "file_share_retention_days" : v.storage_type == "azurefiles" ? "${v.file_share_retention_days}" : null
        "prefix_name" : "${v.prefix_name}"
      }
    ]
  ])

  azurefile_storage_accounts = {
    for k, v in var.storage_accounts : k => v if v.storage_type == "azurefiles"
  }

  blob_storage_accounts = {
    for k, v in var.storage_accounts : k => v if v.storage_type == "blobnfs"
  }

  azurefile_planes = {
    for k, v in local.planes : k => v if v.storage_type == "azurefiles"
  }

  blob_planes = {
    for k, v in local.planes : k => v if v.storage_type == "blobnfs"
  }

  config = jsonencode({
    "external_storage_config" : "${local.planes}"
  })
}
