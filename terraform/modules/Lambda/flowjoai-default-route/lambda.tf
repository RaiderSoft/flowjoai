resource "aws_iam_role" "flowjoai-default-route-lambda-role" {
  name = "${var.app_name}-${terraform.workspace}-default-route-lambda-role"
  assume_role_policy = file("${path.module}/iam/lambda_assume_policy.json")
}

resource "aws_iam_role_policy" "flowjoai-default-route-lambda-policy" {
  name = "${var.app_name}-${terraform.workspace}-default-route-lambda-policy"
  role = aws_iam_role.flowjoai-default-route-lambda-role.id
  policy = file("${path.module}/iam/lambda_policy.json")
}

data "archive_file" "defaultRoute" {
  type        = "zip"
  source_file = "${path.module}/exports.js"
  output_path = "${path.module}/exports.js.zip"
}

resource "aws_lambda_function" "defaultRoute" {
  filename         = data.archive_file.defaultRoute.output_path
  function_name    = "${var.app_name}-default-route-${terraform.workspace}"
  role             = aws_iam_role.flowjoai-default-route-lambda-role.arn
  handler          = "exports.handler"
  runtime          = "nodejs12.x"
  source_code_hash = data.archive_file.defaultRoute.output_base64sha256
}

output "defaultRoute" {
  value = aws_lambda_function.defaultRoute
}