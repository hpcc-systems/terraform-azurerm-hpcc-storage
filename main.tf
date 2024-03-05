resource "random_string" "random" {
  length  = 4
  special = false
  numeric = false
  upper   = false
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
  location            = local.location
  sre_team            = var.metadata.sre_team
  environment         = var.metadata.environment
  product_name        = var.metadata.product_name
  business_unit       = var.metadata.business_unit
  product_group       = var.metadata.product_group
  subscription_type   = var.metadata.subscription_type
  resource_group_type = var.metadata.resource_group_type
  subscription_id     = module.subscription.output.subscription_id
  project             = var.metadata.project
}

module "resource_groups" {
  source = "github.com/Azure-Terraform/terraform-azurerm-resource-group.git?ref=v2.1.0"

  for_each = local.resource_groups

  unique_name = true
  location    = module.metadata.location
  names       = module.metadata.names
  tags        = merge(local.tags, each.value.tags)
}
