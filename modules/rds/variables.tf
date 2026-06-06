variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "allowed_security_group_ids" {
  type = list(string)
}

variable "master_password" {
  type      = string
  sensitive = true
}

variable "master_username" {
  type    = string
  default = "admin"
}

variable "database_name" {
  type    = string
  default = "appdb"
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "allocated_storage_gb" {
  type    = number
  default = 20
}

variable "multi_az" {
  type    = bool
  default = false
}

variable "backup_retention_days" {
  type    = number
  default = 0
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "skip_final_snapshot" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}