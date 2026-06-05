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
    key            = "portfolio/prod/terraform.tfstate"
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
  environment = "prod"
  common_tags = {
    Project     = var.project
    Environment = local.environment
    ManagedBy   = "Terraform"
    CostCenter  = "Engineering"
  }
}

module "vpc" {
  source = "../../modules/vpc"

  project     = var.project
  environment = local.environment
  vpc_cidr    = var.vpc_cidr

  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  nat_gateway_enabled = true

  tags = local.common_tags
}

module "ec2" {
  source = "../../modules/ec2"

  project       = var.project
  environment   = local.environment
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.private_subnet_ids[0]
  instance_type = var.ec2_instance_type

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
    INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
    AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)
    echo "<h1>PROD - ${var.project}</h1><p>Instance: $INSTANCE_ID</p><p>AZ: $AZ</p><p>Managed by Terraform</p>" > /var/www/html/index.html
    echo "OK" > /var/www/html/health
  EOF

  tags = local.common_tags
}

module "rds" {
  source = "../../modules/rds"

  project       = var.project
  environment   = local.environment
  vpc_id        = module.vpc.vpc_id
  subnet_ids    = module.vpc.private_subnet_ids
  instance_class = var.rds_instance_class
  allocated_storage_gb = 20

  master_password = var.db_password
  allowed_security_group_ids = [module.ec2.security_group_id]

  multi_az              = false
  backup_retention_days = 0
  deletion_protection   = false
  skip_final_snapshot   = true

  tags = local.common_tags
}

resource "aws_s3_bucket" "assets" {
  bucket = "${var.project}-prod-assets-485141928127"
  tags   = local.common_tags
}

resource "aws_s3_bucket_versioning" "assets" {
  bucket = aws_s3_bucket.assets.id
  versioning_configuration {
    status = "Enabled"
  }
}
