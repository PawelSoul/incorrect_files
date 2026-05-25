resource "azurerm_resource_group" "rg" {
  name     = "rg-security-audit-demo"
  location = "polandcentral"

  tags = {
    environment = "dev"
    owner       = "security-team"
  }
}

# Expected problems:
# - public_storage: storage account allows public access
# - CKV_AZURE_35: default network access is not denied
# - CKV_AZURE_44: old TLS version is used
resource "azurerm_storage_account" "public_storage_bad" {
  name                     = "pwrpublicbadsa001"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  public_network_access_enabled = true
  allow_nested_items_to_be_public = true
  min_tls_version = "TLS1_0"

  tags = {
    environment = "dev"
    owner       = "security-team"
  }
}

resource "azurerm_storage_account_network_rules" "allow_all_bad" {
  storage_account_id = azurerm_storage_account.public_storage_bad.id

  default_action = "Allow"
  bypass         = ["AzureServices"]
}

# Expected problem:
# - CKV_AZURE_7: blob container public access is not private
resource "azurerm_storage_container" "public_container_bad" {
  name                  = "public-files"
  storage_account_name  = azurerm_storage_account.public_storage_bad.name
  container_access_type = "blob"
}
