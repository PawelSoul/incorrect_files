resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-security-audit-demo"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = {
    environment = "dev"
    owner       = "security-team"
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}

# Expected problem:
# - CKV_AZURE_2 or similar VM/network public exposure check
resource "azurerm_public_ip" "vm_public_ip_bad" {
  name                = "pip-vm-public-bad"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Basic"

  tags = {
    environment = "dev"
    owner       = "security-team"
  }
}

resource "azurerm_network_interface" "nic_bad" {
  name                = "nic-vm-public-bad"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_public_ip_bad.id
  }

  tags = {
    environment = "dev"
    owner       = "security-team"
  }
}

# Expected problem:
# - vm_backup_enabled_tag custom rule: VM does not have backup_enabled = true
resource "azurerm_linux_virtual_machine" "vm_backup_tag_bad" {
  name                = "vm-backup-tag-bad"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.nic_bad.id
  ]

  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCdemoonly demo@example"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = {
    environment = "dev"
    owner       = "security-team"
    # backup_enabled is intentionally missing
  }
}
