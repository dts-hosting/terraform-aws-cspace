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
  comparison_operator = var.log_filter_patterns[each.key].comparison_operator
  datapoints_to_alarm = var.log_filter_patterns[each.key].datapoints_to_alarm
  evaluation_periods  = var.log_filter_patterns[each.key].evaluation_periods
  period              = var.log_filter_patterns[each.key].period
  statistic           = var.log_filter_patterns[each.key].statistic
  threshold           = var.log_filter_patterns[each.key].threshold
  alarm_description   = "${var.log_filter_patterns[each.key].description} for: ${local.name}"

  alarm_actions = [var.sns_topic_arn]
}