# IaC Security & Validation Pipeline - Sample Terraform Configuration
# This demonstrates secure infrastructure patterns that pass all security checks

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.85"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
}

# Variables
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  default     = "rg-iac-demo"
}

# Local values
locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "IaC-Security-Demo"
  }
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}

# Storage Account - Secure Configuration
resource "azurerm_storage_account" "secure" {
  name                     = "stiacsec${var.environment}${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "GRS" # Geo-redundant for DR

  # Security: Enable HTTPS only
  enable_https_traffic_only = true
  min_tls_version          = "TLS1_2"

  # Security: Enable encryption
  infrastructure_encryption_enabled = true

  # Security: Disable public blob access
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = true # Set to false in prod with private endpoints

  # Security: Enable blob versioning and soft delete
  blob_properties {
    versioning_enabled       = true
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }

  # Security: Enable logging
  queue_properties {
    logging {
      delete                = true
      read                  = true
      write                 = true
      version               = "1.0"
      retention_policy_days = 7
    }
  }

  tags = local.common_tags
}

# Random suffix for unique naming
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Key Vault - Secure Configuration
resource "azurerm_key_vault" "secure" {
  name                = "kv-iacsec-${var.environment}-${random_string.suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  # Security: Enable RBAC authorization
  enable_rbac_authorization = true

  # Security: Enable soft delete and purge protection
  soft_delete_retention_days = 7
  purge_protection_enabled   = false # Set to true for production

  # Security: Network rules
  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = [] # Add allowed IPs for production
  }

  tags = local.common_tags
}

# Data sources
data "azurerm_client_config" "current" {}

# Outputs
output "storage_account_name" {
  description = "Storage account name"
  value       = azurerm_storage_account.secure.name
}

output "key_vault_name" {
  description = "Key Vault name"
  value       = azurerm_key_vault.secure.name
}

output "key_vault_uri" {
  description = "Key Vault URI"
  value       = azurerm_key_vault.secure.vault_uri
}

