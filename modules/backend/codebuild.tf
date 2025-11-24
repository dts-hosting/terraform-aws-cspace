resource "aws_codebuild_project" "codebuild" {
  name          = "${local.backend_name}-codebuild"
  description   = "${local.backend_name}-codebuild"
  build_timeout = "60"
  service_role  = aws_iam_role.codebuild_role.arn

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
