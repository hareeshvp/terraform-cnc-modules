resource "random_string" "password" {
  count   = !local.is_postgres_instance_exist && length(var.db_password) == 0 ? 1 : 0
  length  = 16
  special = false
}


resource "azurerm_postgresql_flexible_server" "postgres" {
  name                   = "${var.prefix}psqlserver"
  resource_group_name    = var.rg_name
  location               = var.rg_location
  version                = var.postgresql_version
  administrator_login    = var.db_username
  administrator_password = length(var.db_password) > 0 ? var.db_password : random_string.password.0.result
  storage_mb             = var.db_storage
  sku_name               = var.sku_name
  tags                   = var.tags

}


resource "azurerm_postgresql_flexible_server_configuration" "serverconfig" {
  name      = "require_secure_transport"
  server_id = azurerm_postgresql_flexible_server.postgres.id
  value     = "off"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "postgresqlfwrule" {
  name             = "Postgrescnc"
  server_id        = azurerm_postgresql_flexible_server.postgres.id
  start_ip_address = var.db_firewall_start_ip_address
  end_ip_address   = var.db_firewall_end_ip_address
}
