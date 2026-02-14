# --------------------------
# Set Up
# --------------------------

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

data "azurerm_client_config" "current" {}

locals {
  storage_account_name    = "stcmkdemo${random_string.suffix.result}"
  key_vault_name          = "kv${random_string.suffix.result}"
  storage_account_mi_name = "id-stcmkdemo${random_string.suffix.result}"
}


# --------------------------
# Resource Group
# --------------------------
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# --------------------------
# User Assigned Identity for CMK
# --------------------------
resource "azurerm_user_assigned_identity" "cmk_identity" {
  name                = local.storage_account_mi_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# --------------------------
# Key Vault
# --------------------------
resource "azurerm_key_vault" "kv" {
  name                       = local.key_vault_name
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = true
  soft_delete_retention_days = 90

  rbac_authorization_enabled = true

  public_network_access_enabled = true

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = var.admin_ip_addresses
  }

}

resource "azurerm_role_assignment" "kv_admin" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "time_sleep" "wait_for_kv_admin" {
  depends_on      = [azurerm_role_assignment.kv_admin]
  create_duration = "60s"
}

# --------------------------
# Key Vault Key (CMK)
# --------------------------
resource "azurerm_key_vault_key" "cmk" {
  depends_on = [time_sleep.wait_for_kv_admin]
  name         = "sa-cmk-key"
  key_vault_id = azurerm_key_vault.kv.id
  key_type     = "RSA"
  key_size     = 4096

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

# --------------------------
# Storage Account with CMK
# --------------------------
resource "azurerm_storage_account" "sa" {
  depends_on = [time_sleep.wait_for_role_assignment]

  name                            = local.storage_account_name
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.cmk_identity.id]
  }

  customer_managed_key {
    key_vault_key_id          = azurerm_key_vault_key.cmk.id
    user_assigned_identity_id = azurerm_user_assigned_identity.cmk_identity.id
  }
}

# --------------------------
# RBAC: allow User Assigned Identity to use the CMK
# --------------------------
resource "azurerm_role_assignment" "sa_kv_crypto" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_user_assigned_identity.cmk_identity.principal_id
}

resource "time_sleep" "wait_for_role_assignment" {
  depends_on      = [azurerm_role_assignment.sa_kv_crypto]
  create_duration = "60s"
}