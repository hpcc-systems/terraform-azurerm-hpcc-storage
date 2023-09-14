# Azure - Storage Account for HPCC Systems
<br>

## Providers

| Name    | Version   |
| ------- | --------- |
| azurerm | >= 3.63.0 |
| random  | >= 3.3.0  |
| azuread | >= 2.42.0 |
<br>

### The `owner` block:
This block contains information on the user who is deploying the cluster. This is used as tags and part of some resource names to identify who deployed a given resource and how to contact that user. This block is required.

| Name  | Description                  | Type   | Default | Required |
| ----- | ---------------------------- | ------ | ------- | :------: |
| name  | Name of the admin.           | string | -       |   yes    |
| email | Email address for the admin. | string | -       |   yes    |

<br>
Usage Example:
<br>

    owner = {
        name  = "demo"
        email = "demo@lexisnexisrisk.com"
    }

<br>

### The `disable_naming_conventions` block:
When set to `true`, this attribute drops the naming conventions set forth by the python module. This attribute is optional.

 | Name                       | Description                 | Type | Default | Required |
 | -------------------------- | --------------------------- | ---- | ------- | :------: |
 | disable_naming_conventions | Disable naming conventions. | bool | `false` |    no    |
<br>

### The `metadata` block:
TThe arguments in this block are used as tags and part of resources’ names. This block can be omitted when disable_naming_conventions is set to `true`.

 | Name                | Description                  | Type   | Default | Required |
 | ------------------- | ---------------------------- | ------ | ------- | :------: |
 | project_name        | Name of the project.         | string | ""      |   yes    |
 | product_name        | Name of the product.         | string | hpcc    |    no    |
 | business_unit       | Name of your bussiness unit. | string | ""      |    no    |
 | environment         | Name of the environment.     | string | ""      |    no    |
 | market              | Name of market.              | string | ""      |    no    |
 | product_group       | Name of product group.       | string | ""      |    no    |
 | resource_group_type | Resource group type.         | string | ""      |    no    |
 | sre_team            | Name of SRE team.            | string | ""      |    no    |
 | subscription_type   | Subscription type.           | string | ""      |    no    |
<br>

Usage Example:
<br>

    metadata = {    
        project             = "hpccdemo"
        product_name        = "example"
        business_unit       = "commercial"
        environment         = "sandbox"
        market              = "us"
        product_group       = "contoso"
        resource_group_type = "app"
        sre_team            = "hpccplatform"
        subscription_type   = "dev"
    }

<br>

### The `virtual_network` block:
This block imports metadata of a virtual network deployed outside of this project. This block is optional.

 | Name                | Description                                     | Type        | Default | Required |
 | ------------------- | ----------------------------------------------- | ----------- | ------- | :------: |
 | name                | The name of the private subnet.                 | string      | -       |   yes    |
 | resource_group_name | The name of the virtual network resource group. | string      | -       |   yes    |
 | subnet_ids          | The IDs  of the subnets to authorize access to. | map(string) | -       |   yes    |
 | location            | The location of the virtual network             | string      | -       |   yes    |
<br>

Usage Example:
<br>

    virtual_network = {
        location            = "value"
        name                = "value"
        resource_group_name = "value"
        subnet_ids = {
            "name" = "value"
        }
    }

<br>

### The `storage_accounts` block:
This block deploys the storage accounts for HPCC-Platform data planes. This block is required.

 | Name                                 | Description                                                                         | Type           | Default | Valid Options           | Required |
 | ------------------------------------ | ----------------------------------------------------------------------------------- | -------------- | ------- | ----------------------- | :------: |
 | delete_protection                    | Should deletion be prevented?                                                       | bool           | true    | `true`, `false`         |    no    |
 | prefix_name                          | The prefix name for the storage account. It must be the storage account object key. | string         | -       | -                       |   yes    |
 | storage_type                         | The storage account type.                                                           | string         | -       | `azurefiles`, `blobnfs` |   yes    |
 | authorized_ip_ranges                 | Group of IPs to authorize access to the storage account.                            | Object(string) | `{}`    | -                       |    no    |
 | replication_type                     |
 | subnet_ids                           |
 | file_share_retention_days            |
 | access_tier                          |
 | account_kind                         |
 | account_tier                         |
 | blob_soft_delete_retention_days      |
 | container_soft_delete_retention_days |
 <br>

#### The `var.storage_accounts.planes` block:

 | Name     | Description                                            | Type   | Default | Valid Options   | Required |
 | -------- | ------------------------------------------------------ | ------ | ------- | --------------- | :------: |
 | size     | The size of the share or HPCC data plane               | number | -       | -               |   yes    |
 | rwmany   | The set of permissions for the plane                   | bool   | true    | `true`, `false` |   yes    |
 | protocol | The network file sharing protocol to use for the share | string | `NFS`   | `SMB`, `NFS`    |   yes    |
 | sub_path | The sub path for the HPCC data plane                   | string | -       | -               |   yes    |
 | category | The category for the HPCC data plane                   | string | -       | -               |   yes    |
 | name     | The name of the plane                                  | string | -       | -               |   yes    |
 | sku      | The sku for the plane                                  | string | -       | -               |    no    |
 <br>
 
Usage Example:
<br>

    storage_accounts = {
        adminsvc1 = {
            delete_protection         = true //Set to false to allow deletion
            prefix_name               = "adminsvc1"
            storage_type              = "azurefiles"
            authorized_ip_ranges      = {}
            replication_type          = "ZRS"
            subnet_ids                = {}
            file_share_retention_days = 7
            access_tier               = "Hot"
            account_kind              = "FileStorage"
            account_tier              = "Premium"

            planes = {
            dali = {
                category = "dali"
                name     = "dali"
                sub_path = "dalistorage"
                size     = 100
                sku      = ""
                rwmany   = true
                protocol = "nfs"
            }
            }
        }

        adminsvc2 = {
            delete_protection                    = true //Set to false to allow deletion
            prefix_name                          = "adminsvc2"
            storage_type                         = "blobnfs"
            authorized_ip_ranges                 = {}
            replication_type                     = "ZRS"
            subnet_ids                           = {}
            blob_soft_delete_retention_days      = 7
            container_soft_delete_retention_days = 7
            access_tier                          = "Hot"
            account_kind                         = "StorageV2"
            account_tier                         = "Standard"

            planes = {
            dll = {
                category = "dll"
                name     = "dll"
                sub_path = "queries"
                size     = 100
                sku      = ""
                rwmany   = true
            }

            lz = {
                category = "lz"
                name     = "mydropzone"
                sub_path = "dropzone"
                size     = 100
                sku      = ""
                rwmany   = true
            }

            sasha = {
                category = "sasha"
                name     = "sasha"
                sub_path = "sashastorage"
                size     = 100
                sku      = ""
                rwmany   = true
            }

            debug = {
                category = "debug"
                name     = "debug"
                sub_path = "debug"
                size     = 100
                sku      = ""
                rwmany   = true
            }
            }
        }

        data1 = {
            delete_protection                    = true //Set to false to allow deletion
            prefix_name                          = "data1"
            storage_type                         = "blobnfs"
            authorized_ip_ranges                 = {}
            replication_type                     = "ZRS"
            subnet_ids                           = {}
            blob_soft_delete_retention_days      = 7
            container_soft_delete_retention_days = 7
            access_tier                          = "Hot"
            account_kind                         = "StorageV2"
            account_tier                         = "Standard"

            planes = {
            data = {
                category = "data"
                name     = "data"
                sub_path = "hpcc-data"
                size     = 100
                sku      = ""
                rwmany   = true
            }
            }
        }

        data2 = {
            delete_protection                    = true //Set to false to allow deletion
            prefix_name                          = "data2"
            storage_type                         = "blobnfs"
            authorized_ip_ranges                 = {}
            replication_type                     = "ZRS"
            subnet_ids                           = {}
            blob_soft_delete_retention_days      = 7
            container_soft_delete_retention_days = 7
            access_tier                          = "Hot"
            account_kind                         = "StorageV2"
            account_tier                         = "Standard"

            planes = {
            data = {
                category = "data"
                name     = "data"
                sub_path = "hpcc-data"
                size     = 100
                sku      = ""
                rwmany   = true
            }
            }
        }
    }
<br>

## Usage

    module "storage" {
        source = "../../../terraform-azurerm-hpcc-storage"

        owner                      = {
            name  = "demo"
            email = "demo@lexisnexisrisk.com"
        }
        disable_naming_conventions = false
        metadata                   = {
            project             = "hpccplatform"
            product_name        = "hpccplatform"
            business_unit       = "commercial"
            environment         = "sandbox"
            market              = "us"
            product_group       = "hpcc"
            resource_group_type = "app"
            sre_team            = "hpccplatform"
            subscription_type   = "dev"
            additional_tags     = { "justification" = "testing" }
            location            = "eastus" # Acceptable values: eastus, centralus
        }
        virtual_network            = {
            location            = "value"
            name                = "value"
            resource_group_name = "value"
            subnet_ids = {
                "name" = "value"
            }
        }
        storage_accounts           = {
            adminsvc1 = {
                delete_protection         = true //Set to false to allow deletion
                prefix_name               = "adminsvc1"
                storage_type              = "azurefiles"
                authorized_ip_ranges      = {}
                replication_type          = "ZRS"
                subnet_ids                = {}
                file_share_retention_days = 7
                access_tier               = "Hot"
                account_kind              = "FileStorage"
                account_tier              = "Premium"

                planes = {
                dali = {
                    category = "dali"
                    name     = "dali"
                    sub_path = "dalistorage"
                    size     = 100
                    sku      = ""
                    rwmany   = true
                    protocol = "nfs"
                }
                }
            }

            adminsvc2 = {
                delete_protection                    = true //Set to false to allow deletion
                prefix_name                          = "adminsvc2"
                storage_type                         = "blobnfs"
                authorized_ip_ranges                 = {}
                replication_type                     = "ZRS"
                subnet_ids                           = {}
                blob_soft_delete_retention_days      = 7
                container_soft_delete_retention_days = 7
                access_tier                          = "Hot"
                account_kind                         = "StorageV2"
                account_tier                         = "Standard"

                planes = {
                dll = {
                    category = "dll"
                    name     = "dll"
                    sub_path = "queries"
                    size     = 100
                    sku      = ""
                    rwmany   = true
                }

                lz = {
                    category = "lz"
                    name     = "mydropzone"
                    sub_path = "dropzone"
                    size     = 100
                    sku      = ""
                    rwmany   = true
                }

                sasha = {
                    category = "sasha"
                    name     = "sasha"
                    sub_path = "sashastorage"
                    size     = 100
                    sku      = ""
                    rwmany   = true
                }

                debug = {
                    category = "debug"
                    name     = "debug"
                    sub_path = "debug"
                    size     = 100
                    sku      = ""
                    rwmany   = true
                }
                }
            }

            data1 = {
                delete_protection                    = true //Set to false to allow deletion
                prefix_name                          = "data1"
                storage_type                         = "blobnfs"
                authorized_ip_ranges                 = {}
                replication_type                     = "ZRS"
                subnet_ids                           = {}
                blob_soft_delete_retention_days      = 7
                container_soft_delete_retention_days = 7
                access_tier                          = "Hot"
                account_kind                         = "StorageV2"
                account_tier                         = "Standard"

                planes = {
                data = {
                    category = "data"
                    name     = "data"
                    sub_path = "hpcc-data"
                    size     = 100
                    sku      = ""
                    rwmany   = true
                }
                }
            }

            data2 = {
                delete_protection                    = true //Set to false to allow deletion
                prefix_name                          = "data2"
                storage_type                         = "blobnfs"
                authorized_ip_ranges                 = {}
                replication_type                     = "ZRS"
                subnet_ids                           = {}
                blob_soft_delete_retention_days      = 7
                container_soft_delete_retention_days = 7
                access_tier                          = "Hot"
                account_kind                         = "StorageV2"
                account_tier                         = "Standard"

                planes = {
                data = {
                    category = "data"
                    name     = "data"
                    sub_path = "hpcc-data"
                    size     = 100
                    sku      = ""
                    rwmany   = true
                }
                }
            }
        }
    }