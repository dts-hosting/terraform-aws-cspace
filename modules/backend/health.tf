locals {
  name = var.name
}

resource "aws_cloudwatch_log_metric_filter" "this" {
  for_each = var.log_filter_patterns

  name           = "${local.name}-${each.key}"
  pattern        = each.value.pattern
  log_group_name = aws_cloudwatch_log_group.this.name

  metric_transformation {
    name          = each.key
    namespace     = local.name
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "this" {
  for_each = aws_cloudwatch_log_metric_filter.this

  alarm_name          = "${local.name}-${each.key}"
  namespace           = each.value.metric_transformation[0].namespace
  metric_name         = each.value.metric_transformation[0].name
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 1
  evaluation_periods  = 1
  period              = 300
  statistic           = "Sum"
  threshold           = "1000"
  alarm_description   = "${var.log_filter_patterns[each.key].description} for: ${local.name}"

  alarm_actions = [var.sns_topic_arn]
}