terraform {
  required_version = ">= 1.13.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0"
    }
  }

    backend "azurerm" {
        subscription_id = "66e4a640-274d-4709-b811-3cf8b14871a6"
        resource_group_name   = "infra"
        storage_account_name  = "mssoftwareinfra"
        container_name        = "tfstate"
        key                   = "terraform.tfstate"
        access_key = "/8mOBVxfqp56EJTJTM2sMZW/IpROqI/mRWHHoBybpBkISbSMd/8pUV70sHfhiqA5qZCQ9UoC36uF+ASt2o6Cxw=="
    }
}

provider "azurerm" {
  features {}
  subscription_id = "66e4a640-274d-4709-b811-3cf8b14871a6"
}