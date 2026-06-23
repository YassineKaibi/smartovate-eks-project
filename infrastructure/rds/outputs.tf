output "db_endpoint" {
  description = "Hostname for DB_HOST in the staging values files."
  value       = aws_db_instance.this.address
}

output "db_port" {
  value = aws_db_instance.this.port
}

output "db_security_group_id" {
  value = aws_security_group.rds.id
}

output "app_databases" {
  description = "Create these on the instance after apply (only 'postgres' exists by default)."
  value       = var.app_databases
}
