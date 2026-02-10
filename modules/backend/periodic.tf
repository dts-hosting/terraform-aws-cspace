# Periodic build schedule: trigger CodeBuild on a cron (e.g. for dev).
# Only created when enable_periodic_build is true. The IAM role passed in
# (iam_ecs_task_role_arn) must trust events.amazonaws.com and have
# codebuild:StartBuild permission.

resource "aws_cloudwatch_event_rule" "periodic_build" {
  count                = var.enable_periodic_build ? 1 : 0
  name                 = "${local.backend_name}-codebuild-periodic-rule"
  description          = "Triggers ${local.backend_name} CodeBuild project on schedule"
  schedule_expression  = var.periodic_build_schedule
}

resource "aws_cloudwatch_event_target" "periodic_build" {
  count     = var.enable_periodic_build ? 1 : 0
  target_id = "${local.backend_name}-codebuild-periodic-trigger"
  rule      = aws_cloudwatch_event_rule.periodic_build[0].name
  arn       = aws_codebuild_project.codebuild.id
  role_arn  = var.iam_ecs_task_role_arn
}
