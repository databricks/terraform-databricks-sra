# Define the subnet for the test VM using cidrsubnet function
locals {
  # Decode the JSON response from the ifconfig.co API to get the public IP address of the host machine
  ifconfig_co_json = jsondecode(data.http.my_public_ip.response_body)
}

# Define a variable for the test VM password
variable "test_vm_password" {
  type        = string
  description = "(Required) Password for the test VM"
}

# Create a subnet resource for the test VM
resource "azurerm_subnet" "testvmsubnet" {
  name                 = "${local.prefix}-testvmsubnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [local.subnet_map["testvm"]]
}

# From https://github.com/databricks/terraform-databricks-examples/blob/main/modules/adb-with-private-links-exfiltration-protection/testvm.tf
# Create a network interface resource for the test VM
resource "azurerm_network_interface" "testvmnic" {
  name                = "${local.prefix}-testvm-nic"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "testvmip"
    subnet_id                     = azurerm_subnet.testvmsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.testvmpublicip.id
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

# Create a network security group resource for the test VM
resource "azurerm_network_security_group" "testvm-nsg" {
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
  network_interface_id      = azurerm_network_interface.testvmnic.id
  network_security_group_id = azurerm_network_security_group.testvm-nsg.id
}

# Retrieve the public IP address of the host machine using the ifconfig.co API
data "http" "my_public_ip" { // add your host machine ip into nsg

  url = "https://ifconfig.co/json"
  request_headers = {
    Accept = "application/json"
  }
}

# Create a network security rule to allow RDP traffic to the test VM
resource "azurerm_network_security_rule" "this" {
  name                        = "RDP"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefixes     = [local.ifconfig_co_json.ip]
  destination_address_prefix  = "VirtualNetwork"
  network_security_group_name = azurerm_network_security_group.testvm-nsg.name
  resource_group_name         = azurerm_resource_group.this.name
}

# Create a public IP address resource for the test VM
resource "azurerm_public_ip" "testvmpublicip" {
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
  name                = "pl-test-vm"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  size                = "Standard_F4s_v2"
  admin_username      = "azureuser"
  admin_password      = var.test_vm_password
  network_interface_ids = [
    azurerm_network_interface.testvmnic.id,
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

# Output the public IP address of the test VM
output "test_vm_public_ip" {
  value = azurerm_public_ip.testvmpublicip.ip_address
}

# Output the public IP address of the host machine
output "my_ip_addr" {
  value = local.ifconfig_co_json.ip
}
