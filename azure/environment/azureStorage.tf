

resource "azurerm_storage_account" "testsa" {
  count         = var.scanfarm_enabled ? 1 : 0
  name                     = "${var.prefix}storageac"
  resource_group_name      = var.rg_name
  location                 = var.rg_location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = {
    owner = "varri"
  }
}

resource "azurerm_storage_account_network_rules" "test" {
  count         = var.scanfarm_enabled ? 1 : 0
  resource_group_name  = var.rg_name
  storage_account_name = azurerm_storage_account.testsa[0].name

  default_action             = "Deny"
  ip_rules                   = var.storage_firewall_ip_rules
  virtual_network_subnet_ids = var.vnet_subnetid
  bypass                     = ["AzureServices"]
}

resource "azurerm_storage_container" "bucket" {
  count         = var.scanfarm_enabled ? 1 : 0
  name                  = "${var.prefix}-bucket"
  storage_account_name  = azurerm_storage_account.testsa[0].name
  container_access_type = "private"
}
