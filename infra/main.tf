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
