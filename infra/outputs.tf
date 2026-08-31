output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "alb_dns_name" {
  value = aws_lb.app_alb.dns_name
}

output "ec2_public_ip" {
  value = aws_instance.app_ec2.public_ip
}

output "ec2_public_dns" {
  value = aws_instance.app_ec2.public_dns
}

output "rds_endpoint" {
  value = aws_db_instance.app_rds.endpoint
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app_ecr.repository_url
}
