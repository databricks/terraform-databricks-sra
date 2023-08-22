[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mMissing required argument[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on main.tf line 5, in module "spoke":
[31m│[0m [0m   5: module "spoke" [4m{[0m[0m
[31m│[0m [0m
[31m│[0m [0mThe argument "route_table_id" is required, but no definition was found.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mMissing required argument[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on main.tf line 5, in module "spoke":
[31m│[0m [0m   5: module "spoke" [4m{[0m[0m
[31m│[0m [0m
[31m│[0m [0mThe argument "metastore_id" is required, but no definition was found.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mMissing required argument[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on main.tf line 5, in module "spoke":
[31m│[0m [0m   5: module "spoke" [4m{[0m[0m
[31m│[0m [0m
[31m│[0m [0mThe argument "hub_peering_info" is required, but no definition was found.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mMissing required argument[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on main.tf line 5, in module "spoke":
[31m│[0m [0m   5: module "spoke" [4m{[0m[0m
[31m│[0m [0m
[31m│[0m [0mThe argument "spoke_vnet_cidr" is required, but no definition was found.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mMissing required argument[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on main.tf line 5, in module "spoke":
[31m│[0m [0m   5: module "spoke" [4m{[0m[0m
[31m│[0m [0m
[31m│[0m [0mThe argument "naming_prefix" is required, but no definition was found.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mUnsupported argument[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on main.tf line 7, in module "spoke":
[31m│[0m [0m   7:   [4mproject_name[0m                        = var.project_name[0m
[31m│[0m [0m
[31m│[0m [0mAn argument named "project_name" is not expected here.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mUnsupported argument[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on main.tf line 9, in module "spoke":
[31m│[0m [0m   9:   [4mhub_vnet_name[0m                       = azurerm_virtual_network.this.name[0m
[31m│[0m [0m
[31m│[0m [0mAn argument named "hub_vnet_name" is not expected here.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mUnsupported argument[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on main.tf line 10, in module "spoke":
[31m│[0m [0m  10:   [4mhub_resource_group_name[0m             = azurerm_resource_group.this.name[0m
[31m│[0m [0m
[31m│[0m [0mAn argument named "hub_resource_group_name" is not expected here.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mUnsupported argument[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on main.tf line 11, in module "spoke":
[31m│[0m [0m  11:   [4mfirewall_private_ip[0m                 = azurerm_firewall.this.ip_configuration[0].private_ip_address[0m
[31m│[0m [0m
[31m│[0m [0mAn argument named "firewall_private_ip" is not expected here.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mUnsupported argument[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on main.tf line 12, in module "spoke":
[31m│[0m [0m  12:   [4mspoke_vnet_address_space[0m            = var.spoke_vnet_address_space[0m
[31m│[0m [0m
[31m│[0m [0mAn argument named "spoke_vnet_address_space" is not expected here.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mUnsupported argument[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on main.tf line 14, in module "spoke":
[31m│[0m [0m  14:   [4mprivatelink_subnet_address_prefixes[0m = var.privatelink_subnet_address_prefixes[0m
[31m│[0m [0m
[31m│[0m [0mAn argument named "privatelink_subnet_address_prefixes" is not expected
[31m│[0m [0mhere.
[31m╵[0m[0m
