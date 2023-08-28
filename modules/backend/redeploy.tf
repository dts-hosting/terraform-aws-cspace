resource "aws_lambda_function" "this" {
  filename         = data.archive_file.redeploy.output_path
  function_name    = "${var.name}-redeployer"
  role             = aws_iam_role.this.arn
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  timeout          = 300
  source_code_hash = filebase64sha256(data.archive_file.redeploy.output_path)
  publish          = true

  environment {
    variables = {
      CLUSTER = "${split("/", var.cluster_id)[1]}"
      SERVICE = local.backend_name
    }
  }
}

resource "aws_cloudwatch_event_rule" "this" {
  name          = "${var.name}-redeployer"
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
        "${split(":", var.img)[1]}"
      ],
      "repositoryName": [
        "${regex("/(.*):", var.img)[0]}"
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
