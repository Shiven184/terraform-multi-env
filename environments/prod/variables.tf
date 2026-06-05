variable "aws_region"         { type = string; default = "ap-south-1" }
variable "project"            { type = string; default = "portfolio" }
variable "db_password"        { type = string; sensitive = true }
variable "ec2_instance_type"  { type = string; default = "t3.small" }
variable "rds_instance_class" { type = string; default = "db.t3.micro" }

variable "vpc_cidr" {
  type    = string
  default = "10.1.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.1.11.0/24", "10.1.12.0/24"]
}
