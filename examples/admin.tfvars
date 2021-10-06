admin = {
  name  = "hpccdemo"
  email = "hpccdemo@example.com"
}

metadata = {
  project             = "hpccdemo"
  product_name        = "storageaccount"
  business_unit       = "commercial"
  environment         = "sandbox"
  market              = "us"
  product_group       = "contoso"
  resource_group_type = "app"
  sre_team            = "hpccplatform"
  subscription_type   = "dev"
}

tags = { "justification" = "testing" }

resource_group = {
  unique_name = true
  location    = "eastus2"
}

storage = {
  access_tier              = "Hot"
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  quotas = {
    dali  = 1
    data  = 3
    dll   = 1
    lz    = 1
    sasha = 3
  }
}

# disable_naming_conventions = false # true will enforce all the arguments of the metadata block above
