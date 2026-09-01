resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/${local.name}/app-logs"
  retention_in_days = 7
}
