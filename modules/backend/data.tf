data "archive_file" "redeploy" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/artifacts/redeploy.zip"
}
