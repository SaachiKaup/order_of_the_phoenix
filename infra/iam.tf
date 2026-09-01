resource "aws_iam_role" "app_ec2_role" {
  name = "${local.name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "app_ec2_ssm" {
  role       = aws_iam_role.app_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "app_ec2_ecr_read" {
  role       = aws_iam_role.app_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "app_ec2_profile" {
  name = "${local.name}-ec2-profile"
  role = aws_iam_role.app_ec2_role.name
}

resource "aws_iam_role_policy" "app_ec2_cloudwatch_logs" {
  name = "${local.name}-ec2-cloudwatch-logs"
  role = aws_iam_role.app_ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]

        Resource = "${aws_cloudwatch_log_group.app_logs.arn}:*"
      },
      {
        Effect   = "Allow"
        Action   = "logs:DescribeLogStreams"
        Resource = "*"
      }
    ]
  })
}
