resource "aws_s3_bucket" "flowjoai-bucket" {
    # scope by app name and workspace
    bucket = lower("${var.app_name}-${terraform.workspace}-bucket")
    acl    = "private"

    # these should come from variables.tf and tfvars
    tags = {
        Name        = "flowjoai-v1"
        Environment = "Dev"
    }
}

# Are these just empty directories? If there's no source, then they
# aren't necessary b/c S3 is object storage, not a file system
# resource "aws_s3_bucket_object" "outputs" {
#     # this should refer to the existing object
#     bucket = "flowjoai-bucket"
#     acl    = "private"
#     key    = "outputs/"
# //    source = "nul"
#     depends_on = [aws_s3_bucket.flowjoai-bucket]
# }

# resource "aws_s3_bucket_object" "training" {
#     bucket = "flowjoai-bucket"
#     acl    = "private"
#     key    = "training/"
# //    source = "nul"
#     depends_on = [aws_s3_bucket.flowjoai-bucket]
# }

# resource "aws_s3_bucket_object" "v1_outputs" {
#     bucket = "flowjoai-bucket"
#     acl    = "private"
#     key    = "outputs/v1/"
# //    source = "nul"
#     depends_on = [aws_s3_bucket.flowjoai-bucket]
# }

# resource "aws_s3_bucket_object" "v1_training" {
#     bucket = "flowjoai-bucket"
#     acl    = "private"
#     key    = "training/v1/"
# //    source = "nul"
#     depends_on = [aws_s3_bucket.flowjoai-bucket]
# }


output "flowjoai-bucket" {
  value = aws_s3_bucket.flowjoai-bucket
}
