# Azure Storage Account with Customer Managed Key (CMK) - Example

This repository contains the example code referenced in a blog post demonstrating how to deploy an Azure Storage Account encrypted with a Customer Managed Key (CMK).

## What's Deployed

This Terraform configuration deploys the following Azure resources:

- **Resource Group** - Container for all resources
- **User Assigned Managed Identity** - Used by the Storage Account to access the encryption key
- **Azure Key Vault** - Stores and manages the Customer Managed Key with:
  - RBAC authorization enabled
  - Purge protection enabled
  - Network ACLs to restrict access to specified IP addresses
  - 90-day soft delete retention
- **Key Vault Key** - 4096-bit RSA key used for encrypting the Storage Account
- **Azure Storage Account** - Encrypted using the Customer Managed Key with:
  - Standard tier, LRS replication
  - TLS 1.2 minimum
  - Public blob access disabled
  - User-assigned identity for CMK access
- **RBAC Role Assignments** - Grants necessary permissions for:
  - Administrator access to Key Vault
  - Storage Account identity to use the encryption key

## Prerequisites

- Azure subscription
- Terraform installed
- Azure CLI authenticated
- Your public IP address (for Key Vault network access)

## Usage

1. Copy `terraform.tfvars.example` to `terraform.tfvars` or create it with:
   ```hcl
   subscription_id      = "your-subscription-id"
   admin_ip_addresses   = ["your.ip.address/32"]
   resource_group_name  = "rg-storage-cmk-demo"
   location            = "uksouth"
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Review the planned changes:
   ```bash
   terraform plan
   ```

4. Deploy the resources:
   ```bash
   terraform apply
   ```

## Clean Up

To remove all deployed resources:
```bash
terraform destroy
```

**Note:** Due to purge protection on the Key Vault, the Key Vault will be soft-deleted but not permanently removed. You may need to manually purge it after the soft delete retention period or use Azure CLI to purge it immediately.
