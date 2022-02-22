variable "prefix" {
  description = "A prefix used for all resources in this example"
}

variable "rg_location" {
  default     = "West Europe"
  description = "The Azure Region in which all resources in this example should be provisioned"
}

variable "subscription_id" {
  type        = string
  description = "azure account subscription id"
}

variable "rg_name" {
  description = "name of the azure resource group"
}

variable "db_username" {
  type        = string
  description = "Username for the master DB user. Note: Do NOT use 'user' as the value"
  default     = "psqladmin"
}

variable "db_password" {
  type        = string
  description = "Password for the master DB user; If empty, then random password will be set by default. Note: This will be stored in the state file"
  default     = ""
}

variable "postgresql_version" {
  type        = string
  description = "postgresql DB version"
  default     = "13"
}

variable "db_firewall_start_ip_address" {
  type        = string
  description = "start ip address for the postgres firewall rule"
  default     = "0.0.0.0"
}

variable "db_firewall_end_ip_address" {
  type        = string
  description = "end ip address for the postgres firewall rule"
  default     = "0.0.0.0"
}

variable "db_name" {
  type        = string
  description = "Name of the postgres instance; if empty, then CloudSQL instance will be created"
  default     = ""
}

variable "vnet_subnetid" {
  type        = list(string)
  description = "subnet id to attach with the storage account"
  default     = []
}

variable "storage_firewall_ip_rules" {
  type    = list(string)
  default = ["0.0.0.0/0"]

}

variable "storage_account_replication_type" {
  type    = string
  default = "GRS"
}

variable "scanfarm_enabled" {
  type        = bool
  default     = false
  description = "to enable the scanfarm components"
}

variable "tags" {
  type        = map(string)
  description = "azure Tags to add to all resources created (wherever possible)"
  default = {
    product    = "cnc"
    automation = "dns"
    managedby  = "terraform"
  }
}

variable "sku_name" {
  description = "postgres sku_name "
  default     = "GP_Standard_D4s_v3"
}

variable "db_storage" {
  description = "db storage size in mb"
  type        = number
  default     = 32768
}