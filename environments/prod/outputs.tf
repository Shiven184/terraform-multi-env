output "vpc_id" {
  value = module.vpc.vpc_id
}

output "ec2_instance_id" {
  value = module.ec2.instance_id
}

output "ec2_private_ip" {
  value = module.ec2.private_ip
}

output "db_endpoint" {
  value = module.rds.db_endpoint
}

output "assets_bucket" {
  value = aws_s3_bucket.assets.bucket
}
