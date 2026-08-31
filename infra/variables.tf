variable "project_name" {
  type = string
}

variable "ec2_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "app_port" {
  type    = number
  default = 4000
}

variable "alb_name" {
  type = string
}

variable "ecr_repository_name" {
  type = string
}

variable "rds_db_name" {
  type = string
}

variable "rds_allocated_storage" {
  type    = number
  default = 20
}

variable "github_repository" {
  description = "Your Github repository"
  type        = string
}

variable "aws_region" {
  description = "The AWS region"
  type        = string
}

variable "aws_account_id" {
  description = "The AWS account ID"
  type        = string
}

variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "CIDR for the VPC"
}

variable "vpc_public_subnets" {
  default     = ["10.0.101.0/24"]
  description = "Public subnet for the VPC"
}

variable "vpc_private_subnets" {
  default     = ["10.0.1.0/24"]
  description = "Private subnets for the VPC"
}

variable "rds_db_username" {
  description = "The RDS database username"
  type        = string
  default     = "postgres"
}

variable "rds_instance_type" {
  default     = "db.t3.micro"
  description = "RDS instance type"
}
