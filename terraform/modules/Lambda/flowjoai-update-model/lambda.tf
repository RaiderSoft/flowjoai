resource "aws_iam_role" "flowjoai-update-model-lambda-role" {
  name = "${var.app_name}-${terraform.workspace}-update-model-lambda-role"
  assume_role_policy = file("${path.module}/iam/lambda_assume_policy.json")
}

resource "aws_iam_role_policy" "flowjoai-update-model-lambda-policy" {
  name = "${var.app_name}-${terraform.workspace}-update-model-lambda-policy"
  role = aws_iam_role.flowjoai-update-model-lambda-role.id
  policy = file("${path.module}/iam/lambda_policy.json")
}

data "archive_file" "updateModelFunction" {
  type        = "zip"
  source_file = "${path.module}/exports.js"
  output_path = "${path.module}/exports.js.zip"
}

resource "aws_lambda_function" "updateModelFunction" {
  filename         = data.archive_file.updateModelFunction.output_path
  function_name    = "${var.app_name}-update-model-${terraform.workspace}"
  role             = aws_iam_role.flowjoai-update-model-lambda-role.arn
  handler          = "exports.handler"
  runtime          = "nodejs12.x"
  source_code_hash = data.archive_file.updateModelFunction.output_base64sha256
}

output "updateModelFunction" {
  value = aws_lambda_function.updateModelFunction
}