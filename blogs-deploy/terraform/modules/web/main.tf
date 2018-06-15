
resource "aws_s3_bucket" "site" {
  bucket = "${var.domain}"
  acl = "public-read"

  policy = <<EOF
{
  "Version":"2008-10-17",
  "Statement":[{
    "Sid":"AllowPublicRead",
    "Effect":"Allow",
    "Principal": {"AWS": "*"},
    "Action":["s3:GetObject"],
    "Resource":["arn:aws:s3:::${var.domain}/*"]
  }]
}
EOF

  website {
	index_document = "index.html"
	error_document = "error.html"
  }
}

resource "aws_s3_bucket" "site_www" {
  bucket = "www.${var.domain}"
  acl = "public-read"

  website {
	redirect_all_requests_to = "${var.domain}"
  }


//  policy = <<EOF
//{
//  "Version":"2012-10-17",
//  "Statement":[{
//	"Sid":"PublicReadGetObject",
//        "Effect":"Allow",
//	  "Principal": "*",
//      "Action":["s3:GetObject"],
//      "Resource":["arn:aws:s3:::${var.bucket_name_www}/*"
//      ]
//    }
//  ]
//}
//EOF
}

# IAM sec for the buckets
resource "aws_iam_user_policy" "prod_user_ro" {
  name = "prod"
  user = "${var.iam_user}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${var.domain}",
                "arn:aws:s3:::${var.domain}/*"
            ]
        }
   ]
}
EOF
}

//resource "aws_route53_zone" "main" {
//  name = "${var.domain}"
//}
//
//resource "aws_route53_record" "root_domain" {
//   zone_id = "${aws_route53_zone.main.zone_id}"
//   name = "${var.domain}"
//   type = "A"
//
//  alias {
//    name = "${aws_cloudfront_distribution.cdn.domain_name}"
//    zone_id = "${aws_cloudfront_distribution.cdn.hosted_zone_id}"
//    evaluate_target_health = false
//  }
//}
//
//resource "aws_route53_record" "root_domain_www" {
//   zone_id = "${aws_route53_zone.main.zone_id}"
//   name = "www.${var.domain}"
//   type = "A"
//
//  alias {
//    name = "${aws_s3_bucket.site_www.website_domain}"
//    zone_id = "${aws_s3_bucket.site_www.hosted_zone_id}"
//    evaluate_target_health = false
//  }
//}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    origin_id   = "${var.domain}"
	// Needs to be the website endpoint, not REST endpoint, for resolving
	// folder/ paths' index.html files
	//
	// Otherwise, folder paths like-this/ will throw S3 XML errors for key value
	// not existing, since technically S3 is key-value, not folder-based.
	//
	// REST endpoint - bucket-name.s3.amazonaws.com/
	//
	// Website endpoint - bucket-name.s3-website.us-east-2.amazonaws.com/
	//
	// Source: https://stackoverflow.com/questions/34060394/cloudfront-s3-website-the-specified-key-does-not-exist-when-an-implicit-ind
    domain_name = "${aws_s3_bucket.site.website_endpoint}"

	custom_origin_config {
	  origin_protocol_policy = "http-only"
	  http_port = "80"
	  https_port = "443"
	  origin_ssl_protocols = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
	}
  }

  # If using route53 aliases for DNS we need to declare it here too, otherwise we'll get 403s.
  aliases = ["${var.domain}", "www.${var.domain}"]

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.domain}"

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # The cheapest priceclass
  price_class = "PriceClass_100"

  # This is required to be specified even if it's not used.
  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
