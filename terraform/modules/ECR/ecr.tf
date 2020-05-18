resource "aws_ecr_repository" "fjai-train" {
  name                 = "flowjoai-pytorch-training-v1"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecr_repository" "fjai-infer" {
  name                 = "flowjoai-pytorch-inference-v1"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}