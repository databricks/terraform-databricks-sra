# Define the subnet for the test VM using cidrsubnet function

# Create a subnet resource for the test VM
resource "azurerm_subnet" "testvmsubnet" {
  count = var.is_test_vm_enabled ? 1 : 0

  name                 = "${local.prefix}-testvmsubnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [local.subnet_map["testvm"]]
}

# From https://github.com/databricks/terraform-databricks-examples/blob/main/modules/adb-with-private-links-exfiltration-protection/testvm.tf
# Create a network interface resource for the test VM
resource "azurerm_network_interface" "testvmnic" {
  count = var.is_test_vm_enabled ? 1 : 0

  name                = "${local.prefix}-testvm-nic"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "testvmip"
    subnet_id                     = azurerm_subnet.testvmsubnet[0].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.testvmpublicip[0].id
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

# Create a network security group resource for the test VM
resource "azurerm_network_security_group" "testvm-nsg" {
  count = var.is_test_vm_enabled ? 1 : 0

  name                = "${local.prefix}-testvm-nsg"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

# Associate the network security group with the network interface of the test VM
resource "azurerm_network_interface_security_group_association" "testvmnsgassoc" {
  count = var.is_test_vm_enabled ? 1 : 0

  network_interface_id      = azurerm_network_interface.testvmnic[0].id
  network_security_group_id = azurerm_network_security_group.testvm-nsg[0].id
}

# Create a network security rule to allow RDP traffic to the test VM
resource "azurerm_network_security_rule" "this" {
  count = var.is_test_vm_enabled ? 1 : 0

  name                        = "RDP"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefixes     = [local.ifconfig_co_json.ip]
  destination_address_prefix  = "VirtualNetwork"
  network_security_group_name = azurerm_network_security_group.testvm-nsg[0].name
  resource_group_name         = azurerm_resource_group.this.name
}

# Create a public IP address resource for the test VM
resource "azurerm_public_ip" "testvmpublicip" {
  count = var.is_test_vm_enabled ? 1 : 0

  name                = "${local.prefix}-vmpublicip"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"

  lifecycle {
    ignore_changes = [tags]
  }
}

# Create a Windows virtual machine resource for the test VM
resource "azurerm_windows_virtual_machine" "testvm" {
  count = var.is_test_vm_enabled ? 1 : 0

  name                = "pl-test-vm"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  size                = "Standard_F4s_v2"
  admin_username      = "azureuser"
  admin_password      = var.test_vm_password
  network_interface_ids = [
    azurerm_network_interface.testvmnic[0].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-10"
    sku       = "19h2-pro-g2"
    version   = "latest"
  }

  lifecycle {
    ignore_changes = [tags]
  }
}
