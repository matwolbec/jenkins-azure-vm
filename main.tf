terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
  backend "azurerm" {
  }

}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "default" {
  name     = var.rg
  location = var.locat
  tags = {
    "env"     = var.env_tag
    "project" = "myapp"
  }
}

resource "azurerm_virtual_network" "default" {
  name                = "${var.locat}-${var.vnet}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  address_space       = [var.vnet_prefix]

  tags = {
    env = var.env_tag
  }
}

resource "azurerm_subnet" "default" {
  name                 = "${var.locat}-${var.subnet}"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = [var.subnet_prefix]
}

resource "azurerm_public_ip" "default" {
  name                = "${var.locat}-${var.vm}-ip"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  allocation_method   = "Static"

  tags = {
    env = var.env_tag
  }
}

resource "azurerm_network_security_group" "default" {
  name                = "${var.locat}-${var.vm}-nsg"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  security_rule {
    name                       = "SSH"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 201
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    env = var.env_tag
  }
}

resource "azurerm_network_interface" "default" {
  name                = "${var.locat}-${var.nic}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  ip_configuration {
    name                          = "${var.locat}-${var.subnet}"
    subnet_id                     = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.default.id
  }
}

resource "azurerm_network_interface_security_group_association" "default" {
  network_interface_id      = azurerm_network_interface.default.id
  network_security_group_id = azurerm_network_security_group.default.id
}


resource "azurerm_linux_virtual_machine" "default" {
  name                = "${var.locat}-${var.vm}"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.default.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = "${file("${var.public_key_file}")}"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

output "azurerm_public_ip" {
  value = azurerm_public_ip.default.ip_address
}

resource "local_file" "default" {
  depends_on   = [azurerm_linux_virtual_machine.default]
  filename     = "azurerm_linux_virtual_machine_public_ip"
  content      = azurerm_public_ip.default.ip_address
}