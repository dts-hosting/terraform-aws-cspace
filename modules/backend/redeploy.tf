resource "aws_lambda_function" "this" {
  filename         = data.archive_file.redeploy.output_path
  function_name    = "${local.backend_name}-redeployer"
  role             = aws_iam_role.this.arn
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  timeout          = 300
  source_code_hash = filebase64sha256(data.archive_file.redeploy.output_path)
  publish          = true

  environment {
    variables = {
      CLUSTER = local.env_cluster_name
      SERVICE = local.backend_name
    }
  }
}

resource "aws_cloudwatch_event_rule" "this" {
  name          = "${local.backend_name}-redeployer"
  event_pattern = <<PATTERN
{
  "detail": {
    "eventName": [
      "PutImage"
    ],
    "eventSource": [
      "ecr.amazonaws.com"
    ],
    "requestParameters": {
      "imageTag": [
        "${local.img_tag}"
      ],
      "repositoryName": [
        "${local.img_repository}"
      ]
    }
  },
  "detail-type": [
    "AWS API Call via CloudTrail"
  ],
  "source": [
    "aws.ecr"
  ]
}
PATTERN

}

resource "aws_cloudwatch_event_target" "this" {
  rule      = aws_cloudwatch_event_rule.this.name
  target_id = aws_lambda_function.this.function_name
  arn       = aws_lambda_function.this.arn
}

resource "aws_lambda_permission" "this" {
  statement_id  = "TriggerAllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this.arn
}
