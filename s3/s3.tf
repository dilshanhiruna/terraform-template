# Creates an S3 bucket to store static assets
resource "aws_s3_bucket" "assets_bucket" {
  bucket = "${var.app_name}-${var.environment}-assets"

  tags = {
    AppName     = var.app_name
    Environment = var.environment
  }
}



// pc:begin: log
# create ans S3 bucket to store logs
resource "aws_s3_bucket" "logs_bucket" {
bucket = "${var.app_name}-${var.environment}-logs"

tags = {
AppName     = var.app_name
Environment = var.environment
}
}
// pc:end: log

# Configures ownership controls for the assets S3 bucket
resource "aws_s3_bucket_ownership_controls" "assets_bucket_ownership_controls" {
  bucket = aws_s3_bucket.assets_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

// pc:begin: log
resource "aws_s3_bucket_ownership_controls" "logs_bucket_ownership_controls" {
bucket = aws_s3_bucket.logs_bucket.id
rule {
object_ownership = "BucketOwnerPreferred"
}

}
// pc:end: log

# Enforces public access block for the build artifacts S3 bucket
resource "aws_s3_bucket_public_access_block" "assets_bucket_public_access_block" {
  bucket = aws_s3_bucket.assets_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


// pc:begin: log
resource "aws_s3_bucket_public_access_block" "logs_bucket_public_access_block" {
bucket = aws_s3_bucket.logs_bucket.id

block_public_acls       = true
block_public_policy     = true
ignore_public_acls      = true
restrict_public_buckets = true
}
// pc:end: log
