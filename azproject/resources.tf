resource "azurerm_resource_group" "rg01" {
  name     = var.rg01
  location = var.azlocation
}

resource "azurerm_virtual_network" "vnet1" {
  name                = var.vnet
  location            = var.azlocation
  resource_group_name = azurerm_resource_group.rg01.name
  address_space       = var.vnet-add
}

resource "azurerm_subnet" "mysubnets" {
  for_each             = var.mysubnets
  name                 = each.key
  resource_group_name  = azurerm_resource_group.rg01.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = each.value.address_prefixes
}

resource "azurerm_network_security_group" "nsg1" {
  name                = var.nsg1
  location            = azurerm_resource_group.rg01.location
  resource_group_name = azurerm_resource_group.rg01.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "nsg2" {
  name                = var.nsg2
  location            = azurerm_resource_group.rg01.location
  resource_group_name = azurerm_resource_group.rg01.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "nic" {
  for_each = { for inst in local.vm_instances : inst.name => inst }

  name                = "nic-${each.value.name}"
  location            = azurerm_resource_group.rg01.location
  resource_group_name = azurerm_resource_group.rg01.name

  ip_configuration {
    name                          = "internal-${each.value.name}"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.mysubnets[each.value.subnet_key].id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each            = { for inst in local.vm_instances : inst.name => inst }
  name                = each.value.name
  resource_group_name = azurerm_resource_group.rg01.name
  location            = azurerm_resource_group.rg01.location
  size                = var.vmsize
  admin_username      = "azureuser"
  admin_ssh_key {
    username   = "azureuser" # must match admin_username
    public_key = file("${pathexpand("C:\\devops2026\\azproject\\azure_vm_key.pub")}")
  }


  # Attach NIC dynamically per subnet
  network_interface_ids = [azurerm_network_interface.nic[each.key].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}
# Associate NSG1 with NIC1
resource "azurerm_network_interface_security_group_association" "appnic0nsg" {
  network_interface_id      = azurerm_network_interface.nic["vm-app-subnet-0"].id
  network_security_group_id = azurerm_network_security_group.nsg1.id
}

# Associate NSG1 with NIC1
resource "azurerm_network_interface_security_group_association" "appnic1nsg" {
  network_interface_id      = azurerm_network_interface.nic["vm-app-subnet-1"].id
  network_security_group_id = azurerm_network_security_group.nsg1.id
}

resource "azurerm_network_interface_security_group_association" "dbnic0nsg" {
  network_interface_id      = azurerm_network_interface.nic["vm-db-subnet-0"].id
  network_security_group_id = azurerm_network_security_group.nsg2.id
}

resource "azurerm_network_interface_security_group_association" "dbnic1nsg" {
  network_interface_id      = azurerm_network_interface.nic["vm-db-subnet-1"].id
  network_security_group_id = azurerm_network_security_group.nsg2.id
}