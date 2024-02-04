provider "azurerm" {
  # More information on the authentication methods supported by
  # the AzureRM Provider can be found here:
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
  skip_provider_registration = true
  # More information on the `features` block can be found in the documentation:
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#features
  features {
    # https://github.com/hashicorp/terraform-provider-azurerm/issues/8968
    key_vault {
      purge_soft_delete_on_destroy = false
    }
    # When that feature flag is set, Terraform will skip checking for any Resources within the Resource Group and
    # delete this using the Azure API directly (which will clear up any nested resources).
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

terraform {
  required_version = "1.1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.4.0"
    }
  }

  #backend "azurerm" {}
  backend "local" {}
}

