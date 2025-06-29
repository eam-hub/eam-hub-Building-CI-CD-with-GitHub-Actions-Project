# Fetch current AWS account ID for unique bucket naming
data "aws_caller_identity" "current" {}

# Create an S3 bucket with unique name (appends AWS account ID)
resource "aws_s3_bucket" "env_file_bucket" {
  bucket = "${var.project_name}-${var.env_file_bucket_name}-${data.aws_caller_identity.current.account_id}"

  lifecycle {
    create_before_destroy = false
  }
}

# Upload the environment file from local computer into the S3 bucket
resource "aws_s3_object" "upload_env_file" {
  bucket = aws_s3_bucket.env_file_bucket.id
  key    = var.env_file_name
  source = "./${var.env_file_name}"
}

