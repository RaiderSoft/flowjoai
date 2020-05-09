
resource "aws_s3_bucket" "flowjoai_bucket" {
  bucket = "flowjoai_bucket"
  acl    = "private"

  tags = {
    Name        = "flowjoai-v1"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_object" "outputs" {
    bucket = "flowjoai_bucket"
    acl    = "private"
    key    = "outputs/"
//    source = "nul"
    depends_on = [aws_s3_bucket.flowjoai_bucket]
}

resource "aws_s3_bucket_object" "training" {
    bucket = "flowjoai_bucket"
    acl    = "private"
    key    = "training/"
//    source = "nul"
    depends_on = [aws_s3_bucket.flowjoai_bucket]
}

resource "aws_s3_bucket_object" "v1_outputs" {
    bucket = "flowjoai_bucket"
    acl    = "private"
    key    = "outputs/v1/"
//    source = "nul"
    depends_on = [aws_s3_bucket.flowjoai_bucket]
}

resource "aws_s3_bucket_object" "v1_training" {
    bucket = "flowjoai_bucket"
    acl    = "private"
    key    = "training/v1/"
//    source = "nul"
    depends_on = [aws_s3_bucket.flowjoai_bucket]
}


output "flowjoai_bucket" {
  value = aws_s3_bucket.flowjoai_bucket
}