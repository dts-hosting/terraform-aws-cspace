resource "aws_iam_role" "cs-iam-role" {
  name = "${var.stack}-role"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "cloudtrail.amazonaws.com",
          "codebuild.amazonaws.com",
          "delivery.logs.amazonaws.com",
          "ec2.amazonaws.com",
          "ecs.amazonaws.com",
          "ecs-tasks.amazonaws.com",
          "events.amazonaws.com",
          "lambda.amazonaws.com",
          "s3.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cs-parameter-policy" {
  name = "${var.stack}-parameter-policy"
  role = aws_iam_role.cs-iam-role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:DescribeParameters"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameters"
      ],
      "Resource": [
        "arn:aws:ssm:${aws_region.current.region}:${aws_caller_identity.current.account_id}:parameter/${var.stack}-*",
        "arn:aws:ssm:${aws_region.current.region}:${aws_caller_identity.current.account_id}:parameter/cs-s3-binary-manager-*",
        "arn:aws:ssm:${aws_region.current.region}:${aws_caller_identity.current.account_id}:parameter/cs-gateway-user-password",
        "arn:aws:ssm:${aws_region.current.region}:${aws_caller_identity.current.account_id}:parameter/cs-smtp-email-password"
      ]
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "cs-ecr-ro-policy" {
  name = "${var.stack}-ecr-ro-policy"
  role = aws_iam_role.cs-iam-role.id

  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [{
		"Effect": "Allow",
		"Action": [
			"ecr:GetAuthorizationToken",
			"ecr:BatchCheckLayerAvailability",
			"ecr:GetDownloadUrlForLayer",
			"ecr:GetRepositoryPolicy",
			"ecr:DescribeRepositories",
			"ecr:ListImages",
			"ecr:DescribeImages",
			"ecr:BatchGetImage"
		],
		"Resource": "*"
	}]
}
EOF

}

resource "aws_iam_role_policy" "cs-ecr-w-policy" {
  name = "${var.stack}-ecr-w-policy"
  role = aws_iam_role.cs-iam-role.id

  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [{
		"Effect": "Allow",
		"Action": [
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
		],
		"Resource": "*"
	}]
}
EOF

}

resource "aws_iam_role_policy" "cs-ecs-policy" {
  name = "${var.stack}-ecs-policy"
  role = aws_iam_role.cs-iam-role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "ec2:AuthorizeSecurityGroupIngress",
        "ecr:GetAuthorizationToken",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:DescribeImages",
        "ecs:CreateCluster",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:RunTask",
        "ecs:StartTelemetrySession",
        "ecs:Submit*",
        "ecs:StartTask",
        "ecs:Update*",
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "kms:GenerateDataKey",
        "logs:CreateLogStream",
        "logs:DescribeLogStreams",
        "logs:PutLogEvents",
        "secretsmanager:GetSecretValue",
        "ssm:CreateDocument",
        "ssm:UpdateDocument",
        "ssm:GetDocument",
        "ssm:StartSession",
        "ssm:SendCommand",
        "ssm:DescribeSessions",
        "ssm:GetConnectionStatus",
        "ssm:DescribeInstanceInformation",
        "ssm:DescribeInstanceProperties",
        "ssm:TerminateSession",
        "ssm:ResumeSession",
        "ssm:GetParameters",
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel"
      ],
      "Resource": "*"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "cs-codebuild-policy" {
  name = "${var.stack}-codebuild-policy"
  role = aws_iam_role.cs-iam-role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CloudWatchLogsPolicy",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Sid": "CodeBuildPolicy",
      "Effect": "Allow",
      "Action": [
        "codebuild:StartBuild",
        "codebuild:StopBuild",
        "codebuild:BatchGet*",
        "codebuild:Get*",
        "codebuild:List*"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Sid": "S3ObjectPolicy",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:PutObject"
      ],
      "Resource": [
        "${local.codebuild_input_bucket}/*"
      ]
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "bucket" {
  name = "cspace-service-bucket-policy"
  role = aws_iam_role.cs-iam-role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::cspace-service"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:DeleteObject"
      ],
      "Resource": [
        "arn:aws:s3:::cspace-service/*"
      ]
    },
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "ecs-service-role-attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
  role       = aws_iam_role.cs-iam-role.id
}

resource "aws_iam_role_policy_attachment" "ecs-instance-role-attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  role       = aws_iam_role.cs-iam-role.id
}

resource "aws_iam_role_policy_attachment" "ssm-instance-role-attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  role       = aws_iam_role.cs-iam-role.id
}

resource "aws_s3_bucket" "cs-codebuild-input-bucket" {
  bucket = local.codebuild_input_bucket

  force_destroy = true

  tags = local.tags
}

resource "aws_s3_bucket_public_access_block" "cs-codebuild-input-bucket" {
  bucket = aws_s3_bucket.cs-codebuild-input-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [
    aws_s3_bucket.cs-codebuild-input-bucket
  ]
}

resource "aws_codebuild_project" "codebuild" {
  name          = "${local.backend_name}-codebuild"
  description   = "${local.backend_name}-codebuild"
  build_timeout = "60"
  service_role  = aws_iam_role.cs-iam-role.arn

  environment {
    compute_type    = local.codebuild_compute_type
    image           = local.codebuild_image
    type            = local.codebuild_type
    privileged_mode = true
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  source {
    type     = "S3"
    location = "${local.codebuild_input_bucket}/${local.backend_name}-build.zip"
  }

  tags = local.tags
}
