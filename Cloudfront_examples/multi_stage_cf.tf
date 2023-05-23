### In this script, the stages variable is a list of stage names (e.g., dev, stage, qa, prod). The script creates an S3 bucket for each stage using a naming convention (example-${var.stages[count.index]}-bucket), and then creates a CloudFront distribution for each stage, with the S3 bucket as the origin.
### Make sure to replace the bucket naming convention and other relevant details as per your requirements. Also, ensure that you have the necessary AWS credentials configured with the required permissions to create the resources.


provider "aws" {
  region = "us-east-1"  # Replace with your desired AWS region
}

# List of stages
variable "stages" {
  type    = list(string)
  default = ["dev", "stage", "qa", "prod"]
}

# Create S3 Bucket for each stage
resource "aws_s3_bucket" "stage_buckets" {
  count = length(var.stages)

  bucket = "example-${var.stages[count.index]}-bucket"  # Replace with your desired bucket name prefix
  acl    = "private"
}

# Create CloudFront Distribution for each stage
resource "aws_cloudfront_distribution" "stage_distributions" {
  count = length(var.stages)

  depends_on = [aws_s3_bucket.stage_buckets]

  origin {
    domain_name = aws_s3_bucket.stage_buckets[count.index].bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.stage_buckets[count.index].id}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Example CloudFront Distribution - ${var.stages[count.index]}"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.stage_buckets[count.index].id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.example.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}
