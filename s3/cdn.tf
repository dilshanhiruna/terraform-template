resource "aws_cloudfront_origin_access_identity" "s3_bucket_access_identity" {
  comment = "Access identity for S3 bucket"
}


# Creates a policy to allow CloudFront to access the S3 bucket
resource "aws_s3_bucket_policy" "bucket_policy_assets" {
  bucket = aws_s3_bucket.assets_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Grant CloudFront Origin Access Identity access to S3 bucket"
        Effect = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.s3_bucket_access_identity.iam_arn
        }
        Action = "s3:GetObject"
        Resource = [
          aws_s3_bucket.assets_bucket.arn,
          "${aws_s3_bucket.assets_bucket.arn}/*",
        ]
      },
    ]
  })
}

# Creates a policy to allow CloudFront to access the S3 bucket for logs
resource "aws_s3_bucket_policy" "bucket_policy_logs" {
  bucket = aws_s3_bucket.logs_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Grant CloudFront Origin Access Identity access to S3 bucket for logs"
        Effect = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.s3_bucket_access_identity.iam_arn
        }
        Action = "s3:PutObject"
        Resource = [
          aws_s3_bucket.logs_bucket.arn,
          "${aws_s3_bucket.logs_bucket.arn}/*",
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
    ]
  })
}


# Creates a CloudFront distribution to serve static assets from S3
resource "aws_cloudfront_distribution" "s3_cdn_distribution" {
  origin {
    domain_name = aws_s3_bucket.assets_bucket.bucket_regional_domain_name
    origin_id   = "S3_${var.app_name}-${var.environment}-assets"

    # Restricts access to the S3 bucket to only CloudFront, preventing unauthorized direct access
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.s3_bucket_access_identity.cloudfront_access_identity_path
    }

  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CDN for assets"
  price_class         = "PriceClass_All" # PriceClass_100, PriceClass_200, PriceClass_All
  default_root_object = "index.html"

  // pc:begin: log
logging_config {
bucket          = aws_s3_bucket.logs_bucket.bucket_regional_domain_name
include_cookies = false
prefix          = "cloudfront_logs/"
}
  // pc:end: log

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3_${var.app_name}-${var.environment}-assets"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }


  # Cache behavior for assets
  ordered_cache_behavior {
    path_pattern     = "/assets/*"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3_${var.app_name}-${var.environment}-assets"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"

    response_headers_policy_id = "60669652-455b-4ae9-85a4-c4c02393f86c" # SimpleCORS

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
