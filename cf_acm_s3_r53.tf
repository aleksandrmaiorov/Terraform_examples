provider "aws" {
  region = "us-east-1"  # Replace with your desired AWS region
}

# Create Route 53 Hosted Zone
resource "aws_route53_zone" "example" {
  name = "example.com"  # Replace with your domain name
}

# Create S3 Bucket
resource "aws_s3_bucket" "example" {
  bucket = "example-bucket"  # Replace with your desired bucket name
  acl    = "private"
}

# Create CloudFront Distribution
resource "aws_cloudfront_distribution" "example" {
  depends_on = [aws_s3_bucket.example]

  origin {
    domain_name = aws_s3_bucket.example.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.example.id}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Example CloudFront Distribution"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.example.id}"

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

# Create SSL Certificate using ACM
resource "aws_acm_certificate" "example" {
  domain_name       = "example.com"  # Replace with your domain name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  # DNS Validation
  provisioner "local-exec" {
    command = <<EOF
aws route53 change-resource-record-sets \
  --hosted-zone-id "${aws_route53_zone.example.zone_id}" \
  --change-batch '{
    "Changes": [{
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "_acme-challenge.example.com",
        "Type": "CNAME",
        "TTL": 300,
        "ResourceRecords": [{ "Value": "\"${aws_route53_record_validation.example.fqdn}\"" }]
      }
    }]
  }'
EOF
  }
}

# Create Route 53 record for ACM validation
resource "aws_route53_record" "validation" {
  zone_id = aws_route53_zone.example.zone_id
  name    = "_acme-challenge.example.com"
  type    = "CNAME"
  ttl     = 300
  records = [aws_acm_certificate.example.domain_validation_options.0.resource_record_name]

  depends_on = [aws_acm_certificate.example]
}
