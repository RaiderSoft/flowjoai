resource "aws_ecr_repository" "fjai-train" {
  name                 = "${var.app_name}-pytorch-training-v1-${terraform.workspace}"
  image_tag_mutability = var.tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
}

resource "aws_ecr_repository" "fjai-infer" {
  name                 = "${var.app_name}-pytorch-inference-v1-${terraform.workspace}"
  image_tag_mutability = var.tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
}
