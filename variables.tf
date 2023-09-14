variable "owner" {
  description = "Information for the user who administers the deployment."
  type = object({
    name  = string
    email = string
  })

  validation {
    condition = try(
      regex("hpccdemo", var.owner.name) != "hpccdemo", true
      ) && try(
      regex("hpccdemo", var.owner.email) != "hpccdemo", true
      ) && try(
      regex("@example.com", var.owner.email) != "@example.com", true
    )
    error_message = "Your name and email are required in the owner block and must not contain hpccdemo or @example.com."
  }
}

variable "disable_naming_conventions" {
  description = "Naming convention module."
  type        = bool
  default     = false
}

variable "metadata" {
  description = "Metadata module variables."
  type = object({
    market              = string
    sre_team            = string
    environment         = string
    product_name        = string
    business_unit       = string
    product_group       = string
    subscription_type   = string
    resource_group_type = string
    project             = string
    additional_tags     = map(string)
    location            = string
  })

  default = {
    business_unit       = ""
    environment         = ""
    market              = ""
    product_group       = ""
    product_name        = "hpcc"
    project             = ""
    resource_group_type = ""
    sre_team            = ""
    subscription_type   = ""
    additional_tags     = {}
    location            = ""
  }
}

variable "virtual_network" {
  description = "Subnet IDs"
  type = object({
    name                = string
    resource_group_name = string
    location            = string
    subnet_ids          = map(string)
  })
  default = null
}

variable "storage_accounts" {
  type = map(object({
    delete_protection                    = optional(bool)
    prefix_name                          = string
    storage_type                         = string
    authorized_ip_ranges                 = optional(map(string))
    replication_type                     = optional(string, "ZRS")
    subnet_ids                           = optional(map(string))
    file_share_retention_days            = optional(number, 7)
    access_tier                          = optional(string, "Hot")
    account_kind                         = string
    account_tier                         = string
    blob_soft_delete_retention_days      = optional(number, 7)
    container_soft_delete_retention_days = optional(number, 7)

    planes = map(object({
      category = string
      name     = string
      sub_path = string
      size     = number
      sku      = optional(string)
      rwmany   = bool
      protocol = optional(string, "nfs")
    }))
  }))
}
