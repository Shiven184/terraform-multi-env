resource "aws_db_subnet_group" "rds" {
  name        = "${var.project}-${var.environment}-db-subnet-group"
  description = "RDS subnet group for ${var.project} (${var.environment})"
  subnet_ids  = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}-db-subnet-group"
  })
}

resource "aws_security_group" "rds" {
  name        = "${var.project}-${var.environment}-rds-sg"
  description = "Allow MySQL from app tier only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from app tier"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = var.allowed_security_group_ids
  }

  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}-rds-sg"
  })
}

resource "aws_db_instance" "mysql" {
  identifier     = "${var.project}-${var.environment}-db"
  engine         = "mysql"
  engine_version = "8.0.42"
  instance_class = var.instance_class
  db_name        = var.database_name
  username       = var.master_username
  password       = var.master_password

  allocated_storage     = var.allocated_storage_gb
  max_allocated_storage = var.allocated_storage_gb * 3
  storage_type          = "gp3"
  storage_encrypted     = true

  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  multi_az            = var.multi_az
  publicly_accessible = false
  deletion_protection = var.deletion_protection

  backup_retention_period   = var.backup_retention_days
  backup_window             = "02:00-03:00"
  maintenance_window        = "sun:04:00-sun:05:00"
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.project}-${var.environment}-final-snapshot"

  tags = merge(var.tags, {
    Name        = "${var.project}-${var.environment}-db"
    Environment = var.environment
  })
}
