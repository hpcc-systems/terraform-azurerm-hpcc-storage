resource "random_integer" "random" {
  min = 1
  max = 3
}

resource "random_string" "random" {
  length  = 43
  upper   = false
  number  = false
  special = false
}

module "subscription" {
  source          = "github.com/Azure-Terraform/terraform-azurerm-subscription-data.git?ref=v1.0.0"
  subscription_id = data.azurerm_subscription.current.subscription_id
}

module "naming" {
  source = "github.com/Azure-Terraform/example-naming-template.git?ref=v1.0.0"
}

module "metadata" {
  source = "github.com/Azure-Terraform/terraform-azurerm-metadata.git?ref=v1.5.1"

  naming_rules = module.naming.yaml

  market              = var.metadata.market
  location            = var.resource_group.location
  sre_team            = var.metadata.sre_team
  environment         = var.metadata.environment
  product_name        = var.metadata.product_name
  business_unit       = var.metadata.business_unit
  product_group       = var.metadata.product_group
  subscription_type   = var.metadata.subscription_type
  resource_group_type = var.metadata.resource_group_type
  subscription_id     = data.azurerm_subscription.current.id
  project             = var.metadata.project
}

module "resource_group" {
  source = "github.com/Azure-Terraform/terraform-azurerm-resource-group.git?ref=v2.0.0"

  unique_name = var.resource_group.unique_name
  location    = var.resource_group.location
  names       = local.names
  tags        = local.tags
}

resource "azurerm_storage_account" "storage_account" {

  name                     = lower(try("${var.admin.name}hpccsa${random_integer.random.result}", "hpccsa${random_integer.random.result}404"))
  resource_group_name      = module.resource_group.name
  location                 = module.resource_group.location
  account_tier             = var.storage.account_tier
  account_replication_type = var.storage.account_replication_type
  min_tls_version          = "TLS1_2"
  tags                     = local.tags
}

resource "azurerm_storage_share" "storage_shares" {
  for_each = local.storage_shares

  name                 = each.key
  storage_account_name = azurerm_storage_account.storage_account.name
  quota                = each.value

  acl {
    id = random_string.random.result

    access_policy {
      permissions = "rwdl"
    }
  }
}
