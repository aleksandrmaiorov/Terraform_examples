provider "aws" {
  region = "us-east-1"  # Update with your desired region
}

resource "aws_route53_zone" "example_zone" {
  name = "example.com"  # Replace with your desired domain name
}

resource "aws_s3_bucket" "example_bucket" {
  bucket = "example-bucket"  # Replace with your desired bucket name
  acl    = "private"

  tags = {
    Name = "Example Bucket"
  }
}

resource "aws_cloudfront_distribution" "example_distribution" {
  origin {
    domain_name = aws_s3_bucket.example_bucket.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.example_bucket.id}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  http_version        = "http2"
  price_class         = "PriceClass_100"  # Update with your desired price class
  default_root_object = "index.html"  # Replace with your desired default root object

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "S3-${aws_s3_bucket.example_bucket.id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "Example Distribution"
  }
}
