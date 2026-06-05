terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-485141928127"
    key            = "portfolio/dev/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

locals {
  environment = "dev"
  common_tags = {
    Project     = var.project
    Environment = local.environment
    ManagedBy   = "Terraform"
  }
}

module "vpc" {
  source = "../../modules/vpc"

  project     = var.project
  environment = local.environment
  vpc_cidr    = var.vpc_cidr

  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  nat_gateway_enabled = false

  tags = local.common_tags
}

module "ec2" {
  source = "../../modules/ec2"

  project       = var.project
  environment   = local.environment
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.public_subnet_ids[0]
  instance_type = var.ec2_instance_type

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Dev - ${var.project}</h1><p>Managed by Terraform</p><p>Environment: dev</p>" > /var/www/html/index.html
    echo "OK" > /var/www/html/health
  EOF

  tags = local.common_tags
}

module "rds" {
  source = "../../modules/rds"

  project       = var.project
  environment   = local.environment
  vpc_id        = module.vpc.vpc_id
  subnet_ids    = module.vpc.public_subnet_ids
  instance_class = "db.t3.micro"
  allocated_storage_gb = 20

  master_password = var.db_password
  allowed_security_group_ids = [module.ec2.security_group_id]

  multi_az              = false
  backup_retention_days = 0
  skip_final_snapshot   = true

  tags = local.common_tags
}

resource "aws_s3_bucket" "assets" {
  bucket = "${var.project}-dev-assets-485141928127"
  tags   = local.common_tags
}
