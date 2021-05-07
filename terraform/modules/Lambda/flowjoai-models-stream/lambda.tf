resource "aws_iam_role" "flowjoai-models-stream-lambda-role" {
  name = "${var.app_name}-${terraform.workspace}-models-stream-lambda-role"
  assume_role_policy = file("${path.module}/iam/lambda_assume_policy.json")
}

resource "aws_iam_role_policy" "flowjoai-models-stream-lambda-policy" {
  name = "${var.app_name}-${terraform.workspace}-models-stream-lambda-policy"
  role = aws_iam_role.flowjoai-models-stream-lambda-role.id
  policy = file("${path.module}/iam/lambda_policy.json")
}

data "archive_file" "modelsStreamFunction" {
  type        = "zip"
  source_file = "${path.module}/exports.js"
  output_path = "${path.module}/exports.js.zip"
}

resource "aws_lambda_function" "modelsStreamFunction" {
  filename         = data.archive_file.modelsStreamFunction.output_path
  function_name    = "${var.app_name}-models-stream-${terraform.workspace}"
  role             = aws_iam_role.flowjoai-models-stream-lambda-role.arn
  handler          = "exports.handler"
  runtime          = "nodejs12.x"
  source_code_hash = data.archive_file.modelsStreamFunction.output_base64sha256
}

output "modelsStreamFunction" {
  value = aws_lambda_function.modelsStreamFunction
}