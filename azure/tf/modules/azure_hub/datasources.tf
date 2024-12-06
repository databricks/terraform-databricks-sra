# Retrieve the current Azure client configuration
data "azurerm_client_config" "current" {}

# Retrieve the public IP address of the host machine using the ifconfig.co API
data "http" "my_public_ip" { // add your host machine ip into nsg
  url = "https://ifconfig.co/json"
  request_headers = {
    Accept = "application/json"
  }
}
