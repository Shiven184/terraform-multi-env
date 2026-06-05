aws_region        = "ap-south-1"
project           = "portfolio"
ec2_instance_type = "t3.micro"

vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]

# db_password is set via GitHub Secret TF_VAR_db_password
# Never put real passwords in tfvars files
