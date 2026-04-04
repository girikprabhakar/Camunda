# please create an AWS S3 bucket and an object in it
resource "aws_s3_bucket" "my_bucket" {
    bucket = var.bucket_name
}
resource "aws_s3_object" "upload_file" {
    bucket = aws_s3_bucket.my_bucket.id
    key    = "${var.object_name}"
    source = "${path.root}/${var.config_filename}"
}