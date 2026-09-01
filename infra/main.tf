data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
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

resource "aws_instance" "app_ec2" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.ec2_instance_type
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.app_ec2_sg.id]
  key_name                    = var.ec2_key_name

  tags = {
    Name = "${local.name}-app-instance"
  }
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

resource "aws_security_group_rule" "app_ec2_ssh" {
  type              = "ingress"
  security_group_id = aws_security_group.app_ec2_sg.id
  cidr_blocks       = [var.ssh_allowed_cidr]
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
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

resource "aws_lb" "app_alb" {
  name               = "${local.name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.app_alb_sg.id]
  subnets            = module.vpc.public_subnets
}

resource "aws_lb_target_group" "app_alb_tg" {
  name        = "${local.name}-alb-tg"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_alb_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "app_alb_tg_attachment" {
  target_group_arn = aws_lb_target_group.app_alb_tg.arn
  target_id        = aws_instance.app_ec2.id
  port             = var.app_port
}

resource "aws_db_subnet_group" "app_rds" {
  name       = "${local.name}-rds-subnet-group"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_db_instance" "app_rds" {
  identifier             = "${local.name}-db"
  engine                 = "postgres"
  instance_class         = var.rds_instance_type
  allocated_storage      = var.rds_allocated_storage
  db_name                = var.rds_db_name
  username               = var.rds_db_username
  password               = var.rds_db_password
  db_subnet_group_name   = aws_db_subnet_group.app_rds.name
  vpc_security_group_ids = [aws_security_group.app_rds_sg.id]

  publicly_accessible = false
  skip_final_snapshot = true
}

resource "aws_ecr_repository" "app_ecr" {
  name                 = "${local.name}-ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
