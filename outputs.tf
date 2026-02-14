output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "user_assigned_identity_id" {
  description = "The ID of the user-assigned identity for CMK"
  value       = azurerm_user_assigned_identity.cmk_identity.id
}

output "key_vault_name" {
  description = "The name of the Key Vault"
  value       = azurerm_key_vault.kv.name
}

output "key_vault_id" {
  description = "The ID of the Key Vault"
  value       = azurerm_key_vault.kv.id
}

output "storage_account_name" {
  description = "The name of the Storage Account"
  value       = azurerm_storage_account.sa.name
}

output "storage_account_id" {
  description = "The ID of the Storage Account"
  value       = azurerm_storage_account.sa.id
}

output "cmk_key_id" {
  description = "The ID of the Customer Managed Key"
  value       = azurerm_key_vault_key.cmk.id
}
