data "archive_file" "redeploy" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/redeploy.zip"
}

data "aws_ssm_parameter" "storage_key" {
  name = var.s3_storage_key_param
}

data "aws_ssm_parameter" "storage_secret" {
  name = var.s3_storage_secret_param
}
