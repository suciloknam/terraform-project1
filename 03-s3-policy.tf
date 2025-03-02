resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for CloudFront to access private S3 bucket"
}

#resource "aws_s3_bucket" "example" {
#  bucket = "my-new-test-bucket1089"  # Replace with your desired bucket name

#  tags = {
#    Name        = "My bucket"
#    Environment = "Dev"
#  }
#}


resource "aws_s3_bucket_policy" "allow_cloudfront_access" {
  bucket = aws_s3_bucket.main_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontAccess"
        Effect = "Allow"
        Principal = {
          AWS = "${aws_cloudfront_origin_access_identity.oai.iam_arn}"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.main_bucket.arn}/*"
      }
    ]
  })
}
