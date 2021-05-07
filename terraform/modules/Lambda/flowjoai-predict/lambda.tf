resource "aws_iam_role" "flowjoai-predict-lambda-role" {
  name = "${var.app_name}-${terraform.workspace}-predict-lambda-role"
  assume_role_policy = file("${path.module}/iam/lambda_assume_policy.json")
}

resource "aws_iam_role_policy" "flowjoai-predict-lambda-policy" {
  name = "${var.app_name}-${terraform.workspace}-predict-lambda-policy"
  role = aws_iam_role.flowjoai-predict-lambda-role.id
  policy = file("${path.module}/iam/lambda_policy.json")
}

data "archive_file" "predictFunction" {
  type        = "zip"
  source_file = "${path.module}/exports.js"
  output_path = "${path.module}/exports.js.zip"
}

resource "aws_lambda_function" "predictFunction" {
  filename         = data.archive_file.predictFunction.output_path
  function_name    = "${var.app_name}-predict-${terraform.workspace}"
  role             = aws_iam_role.flowjoai-predict-lambda-role.arn
  handler          = "exports.handler"
  runtime          = "nodejs12.x"
  source_code_hash = data.archive_file.predictFunction.output_base64sha256
}

output "predictFunction" {
  value = aws_lambda_function.predictFunction
}