resource "aws_iam_role" "this" {
  name = local.backend_name
  path = "/"

  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "this" {
  role   = aws_iam_role.this.name
  policy = aws_iam_role_policy.ECSTaskPassRole.arn
}

resource "aws_iam_role_policy_attachments_exclusive" "this" {
  role = aws_iam_role.this.name
  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonECS_FullAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",
    "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess",
    aws_iam_role_policy.ECSTaskPassRole.arn
  ]
}

data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com",
        "ecs.amazonaws.com",
        "ecs-tasks.amazonaws.com",
        "events.amazonaws.com",
        "lambda.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role_policy" "ECSTaskPassRole" {
  name   = "ECSTaskPassRole"
  policy = data.aws_iam_policy_document.ecs_task_pass_role.json
}

data "aws_iam_policy_document" "ecs_task_pass_role" {
  statement {
    actions   = ["iam:PassRole"]
    resources = ["*"]
  }
}
