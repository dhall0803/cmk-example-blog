variable "subscription_id" {
  description = "The Azure subscription ID"
  type        = string
}

variable "admin_ip_addresses" {
  description = "Comma-separated list of IP addresses in CIDR notation allowed to access the Key Vault"
  type        = list(string)
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "rg-storage-cmk-demo"
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "uksouth"
}

