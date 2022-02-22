locals {
  is_postgres_instance_exist = length(var.db_name) > 0 ? true : false
}
