data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  name = var.project_name
  azs  = slice(data.aws_availability_zones.available.names, 0, 2)
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.name
  cidr = var.vpc_cidr

  azs             = local.azs
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_security_group" "app_ec2_sg" {
  name        = "${local.name}-ec2-sg"
  description = "Security group for the EC2 app host"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "app_ec2_from_alb" {
  type                     = "ingress"
  security_group_id        = aws_security_group.app_ec2_sg.id
  source_security_group_id = aws_security_group.app_alb_sg.id
  from_port                = var.app_port
  to_port                  = var.app_port
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "app_ec2_egress_all" {
  type              = "egress"
  security_group_id = aws_security_group.app_ec2_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
}

resource "aws_security_group" "app_alb_sg" {
  name        = "${local.name}-alb-sg"
  description = "Security group for the application load balancer"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "app_alb_ingress_http" {
  type              = "ingress"
  security_group_id = aws_security_group.app_alb_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
}

resource "aws_security_group_rule" "app_alb_ingress_https" {
  type              = "ingress"
  security_group_id = aws_security_group.app_alb_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
}

resource "aws_security_group_rule" "app_alb_egress_ec2" {
  type                     = "egress"
  security_group_id        = aws_security_group.app_alb_sg.id
  source_security_group_id = aws_security_group.app_ec2_sg.id
  from_port                = var.app_port
  to_port                  = var.app_port
  protocol                 = "tcp"
}

resource "aws_security_group" "app_rds_sg" {
  name        = "${local.name}-rds-sg"
  description = "Security group for the RDS database"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "app_rds_ingress_postgres" {
  type                     = "ingress"
  security_group_id        = aws_security_group.app_rds_sg.id
  source_security_group_id = aws_security_group.app_ec2_sg.id
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
}

