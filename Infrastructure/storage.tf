resource "aws_s3_bucket" "s3_landingzone" {
  bucket = "${var.environment}-${var.s3_landingzone_name}"

  tags = {
    Name        = "${var.environment}-s3-landingzone"
    Environment = var.environment
    Purpose     = "Raw data storage"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_landingzone_public_access_block" {
    bucket = aws_s3_bucket.s3_landingzone.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true 

}

resource "aws_s3_bucket" "s3_exportzone" {
  bucket = "${var.environment}-${var.s3_exportzone_name}"

  tags = {
    Name        = "${var.environment}-s3-exportzone"
    Environment = var.environment
    Purpose     = "Curated data for sharing"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_exportzone_public_access_block" {
    bucket = aws_s3_bucket.s3_exportzone.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  
}