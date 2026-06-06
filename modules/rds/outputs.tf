output "db_endpoint" {
  value = aws_db_instance.mysql.endpoint
}

output "db_host" {
  value = aws_db_instance.mysql.address
}

output "db_port" {
  value = aws_db_instance.mysql.port
}

output "db_name" {
  value = aws_db_instance.mysql.db_name
}

output "rds_security_group_id" {
  value = aws_security_group.rds.id
}
