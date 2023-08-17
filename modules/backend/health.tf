locals {
  name = var.name
}

# HEALTH
module "notify_slack" {
  source  = "terraform-aws-modules/notify-slack/aws"
  version = "~> 4.0"

  sns_topic_name   = aws_sns_topic.this.name
  create_sns_topic = false

  lambda_function_name = "${var.name}-notify_slack"

  slack_webhook_url = var.slack_webhook_url
  slack_channel     = var.slack_channel
  slack_username    = var.slack_username

  depends_on = [aws_sns_topic.this]
}

resource "aws_sns_topic" "this" {
  name = "${local.name}-health"
}

resource "aws_cloudwatch_metric_alarm" "db-cpu-util" {
  alarm_name          = "${local.name}-db-cpu-util"
  namespace           = "AWS/RDS"
  metric_name         = "CPUUtilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  period              = "300"
  statistic           = "Average"
  threshold           = "90"
  alarm_description   = "RDS High CPU Load Alarm"
  unit                = "Percent"

  dimensions = {
    DBInstanceIdentifier = var.db_id
  }

  alarm_actions = [aws_sns_topic.this.arn]
}

# RDS RAM
resource "aws_cloudwatch_metric_alarm" "db-disk-capacity" {
  alarm_name          = "${local.name}-db-disk-capacity"
  namespace           = "AWS/RDS"
  metric_name         = "FreeStorageSpace"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"
  threshold           = "10737418240" # 10GB
  alarm_description   = "RDS Disk Capacity Warning Alarm"
  unit                = "Bytes"

  dimensions = {
    DBInstanceIdentifier = var.db_id
  }

  alarm_actions = [aws_sns_topic.this.arn]
}

resource "aws_cloudwatch_metric_alarm" "db-ram-capacity" {
  alarm_name          = "${local.name}-db-ram-capacity"
  namespace           = "AWS/RDS"
  metric_name         = "FreeableMemory"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"
  threshold           = var.database_low_ram_threshold
  alarm_description   = "RDS RAM Capacity Warning Alarm"
  unit                = "Bytes"

  dimensions = {
    DBInstanceIdentifier = var.db_id
  }

  alarm_actions = [aws_sns_topic.this.arn]
}

resource "aws_cloudwatch_metric_alarm" "db-io-credit" {
  alarm_name          = "${local.name}-db-io-credit"
  namespace           = "AWS/RDS"
  metric_name         = "BurstBalance"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  period              = "300"
  statistic           = "Average"
  threshold           = "20"
  alarm_description   = "RDS I/O Credits Exhausted Alarm"
  unit                = "Percent"

  dimensions = {
    DBInstanceIdentifier = var.db_id
  }

  alarm_actions = [aws_sns_topic.this.arn]
}

resource "aws_cloudwatch_metric_alarm" "bastion-status-checks" {
  alarm_description   = "Bastion EC2 status check failed"
  alarm_name          = "${local.name}-bastion_status_check_failed"
  namespace           = "AWS/EC2"
  metric_name         = "StatusCheckFailed"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "1.0"

  dimensions = {
    InstanceId = var.bastion_arn
  }

  alarm_actions = [aws_sns_topic.this.arn]
}
