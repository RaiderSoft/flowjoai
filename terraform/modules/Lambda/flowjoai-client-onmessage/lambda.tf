resource "aws_iam_role" "flowjoai-client-onmessage-lambda-role" {
  name               = "${var.app_name}-${terraform.workspace}-client-onmessage-lambda-role"
  assume_role_policy = file("${path.module}/iam/lambda_assume_policy.json")
}

resource "aws_iam_role_policy" "flowjoai-client-onmessage-lambda-policy" {
  name   = "${var.app_name}-${terraform.workspace}-client-onmessage-lambda-policy"
  role   = aws_iam_role.flowjoai-client-onmessage-lambda-role.id
  policy = file("${path.module}/iam/lambda_policy.json")
}

data "archive_file" "onmessageFunction" {
  type        = "zip"
  source_file = "${path.module}/exports.js"
  output_path = "${path.module}/exports.js.zip"
}

resource "aws_lambda_function" "onmessageFunction" {
  filename         = data.archive_file.onmessageFunction.output_path
  function_name    = "${var.app_name}-client-onmessage-${terraform.workspace}"
  role             = aws_iam_role.flowjoai-client-onmessage-lambda-role.arn
  handler          = "exports.handler"
  runtime          = "nodejs12.x"
  source_code_hash = data.archive_file.onmessageFunction.output_base64sha256
}

output "onmessageFunction" {
  value = aws_lambda_function.onmessageFunction
}
