resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/${local.name}/app-logs"
  retention_in_days = 7
}

resource "aws_cloudwatch_dashboard" "app_dashboard" {
  dashboard_name = "${local.name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          title  = "EC2 CPU Utilization"
          region = var.aws_region
          view   = "timeSeries"
          stat   = "Average"
          period = 300

          metrics = [
            [
              "AWS/EC2",
              "CPUUtilization",
              "InstanceId",
              aws_instance.app_ec2.id
            ]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          title  = "RDS CPU Utilization"
          region = var.aws_region
          view   = "timeSeries"
          stat   = "Average"
          period = 300

          metrics = [
            [
              "AWS/RDS",
              "CPUUtilization",
              "DBInstanceIdentifier",
              aws_db_instance.app_rds.identifier
            ]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          title  = "ALB Healthy Hosts"
          region = var.aws_region
          view   = "timeSeries"
          stat   = "Average"
          period = 300

          metrics = [
            [
              "AWS/ApplicationELB",
              "HealthyHostCount",
              "TargetGroup",
              aws_lb_target_group.app_alb_tg.arn_suffix,
              "LoadBalancer",
              aws_lb.app_alb.arn_suffix
            ]
          ]
        }
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "system_logs" {
  name              = "/${local.name}/system-logs"
  retention_in_days = 7
}

resource "aws_ssm_parameter" "cloudwatch_agent_config" {
  name = "AmazonCloudWatch-${local.name}"
  type = "String"

  value = file("${path.module}/config/cloudwatch_agent.json")
}

resource "aws_cloudwatch_dashboard" "app_traffic_dashboard" {
  dashboard_name = "${local.name}-traffic-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 8
        height = 6

        properties = {
          title  = "ALB Request Count"
          region = var.aws_region
          view   = "timeSeries"
          stat   = "Sum"
          period = 300

          metrics = [
            [
              "AWS/ApplicationELB",
              "RequestCount",
              "LoadBalancer",
              aws_lb.app_alb.arn_suffix
            ]
          ]
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 0
        width  = 8
        height = 6

        properties = {
          title  = "ALB 5xx Count"
          region = var.aws_region
          view   = "timeSeries"
          stat   = "Sum"
          period = 300

          metrics = [
            [
              "AWS/ApplicationELB",
              "HTTPCode_ELB_5XX_Count",
              "LoadBalancer",
              aws_lb.app_alb.arn_suffix
            ]
          ]
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 0
        width  = 8
        height = 6

        properties = {
          title  = "Target Response Time"
          region = var.aws_region
          view   = "timeSeries"
          stat   = "Average"
          period = 300

          metrics = [
            [
              "AWS/ApplicationELB",
              "TargetResponseTime",
              "LoadBalancer",
              aws_lb.app_alb.arn_suffix
            ]
          ]
        }
      }
    ]
  })
}
