resource "aws_iam_role" "flowjoai-client-onessage-lambda-role" {
  name               = "${var.app_name}-${terraform.workspace}-client-onessage-lambda-role"
  assume_role_policy = file("${path.module}/iam/lambda_assume_policy.json")
}

resource "aws_iam_role_policy" "flowjoai-client-onessage-lambda-policy" {
  name   = "${var.app_name}-${terraform.workspace}-client-onessage-lambda-policy"
  role   = aws_iam_role.flowjoai-client-onessage-lambda-role.id
  policy = file("${path.module}/iam/lambda_policy.json")
}

data "archive_file" "onMessageFunction" {
  type        = "zip"
  source_file = "${path.module}/exports.js"
  output_path = "${path.module}/exports.js.zip"
}

resource "aws_lambda_function" "onMessageFunction" {
  filename         = data.archive_file.onMessageFunction.output_path
  function_name    = "${var.app_name}-client-onessage-${terraform.workspace}"
  role             = aws_iam_role.flowjoai-client-onessage-lambda-role.arn
  handler          = "exports.handler"
  runtime          = "nodejs12.x"
  source_code_hash = data.archive_file.onMessageFunction.output_base64sha256
}

output "onMessageFunction" {
  value = aws_lambda_function.onMessageFunction
}
