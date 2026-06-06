variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "root_volume_size_gb" {
  type    = number
  default = 30
}

variable "ssh_allowed_cidrs" {
  type    = list(string)
  default = ["10.0.0.0/8"]
}

variable "user_data" {
  type    = string
  default = "#!/bin/bash\nyum update -y"
}

variable "tags" {
  type    = map(string)
  default = {}
}
