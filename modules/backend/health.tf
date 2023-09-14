resource "aws_cloudwatch_log_metric_filter" "this" {
  for_each = local.log_filter_patterns

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
  comparison_operator = local.log_filter_patterns[each.key].comparison_operator
  datapoints_to_alarm = local.log_filter_patterns[each.key].datapoints_to_alarm
  evaluation_periods  = local.log_filter_patterns[each.key].evaluation_periods
  period              = local.log_filter_patterns[each.key].period
  statistic           = local.log_filter_patterns[each.key].statistic
  threshold           = local.log_filter_patterns[each.key].threshold
  alarm_description   = "${local.log_filter_patterns[each.key].description} for: ${local.name}"

  alarm_actions = [local.sns_topic_arn]
}