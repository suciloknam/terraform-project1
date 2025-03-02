resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for CloudFront to access private S3 bucket"
}

resource "aws_cloudfront_distribution" "multiorigin_distribution" {
  enabled = true
  
  # Origin configuration for S3
  origin {
    domain_name = aws_s3_bucket.main_bucket.bucket_regional_domain_name
    origin_id   = "S3Origin"
    
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }


  # Origin configuration for EC2
  origin {
    domain_name = aws_instance.web.public_dns
    origin_id   = "EC2Origin"
    
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # Default cache behavior (for S3)
    


  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3Origin"
    
    cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"  # CachingDisabled policy ID
    
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  # Additional cache behavior (for EC2)
  ordered_cache_behavior {
    path_pattern     = "/api/*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "EC2Origin"
    
    cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"  # CachingDisabled policy ID
    
    viewer_protocol_policy = "allow-all"
   
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  price_class = "PriceClass_100"
}
