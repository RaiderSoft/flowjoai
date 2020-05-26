resource "aws_iam_role" "flowjoai-client-connect-lambda-role" {
  name               = "${var.app_name}-${terraform.workspace}-client-connect-lambda-role"
  assume_role_policy = file("${path.module}/iam/lambda_assume_policy.json")
}

resource "aws_iam_role_policy" "flowjoai-client-connect-lambda-policy" {
  name   = "${var.app_name}-${terraform.workspace}-client-connect-lambda-policy"
  role   = aws_iam_role.flowjoai-client-connect-lambda-role.id
  policy = file("${path.module}/iam/lambda_policy.json")
}

data "archive_file" "connectFunction" {
  type        = "zip"
  source_file = "${path.module}/exports.js"
  output_path = "${path.module}/exports.js.zip"
}

resource "aws_lambda_function" "connectFunction" {
  filename         = data.archive_file.connectFunction.output_path
  function_name    = "${var.app_name}-client-connect-${terraform.workspace}"
  role             = aws_iam_role.flowjoai-client-connect-lambda-role.arn
  handler          = "exports.handler"
  runtime          = "nodejs12.x"
  source_code_hash = data.archive_file.connectFunction.output_base64sha256
}

output "connectFunction" {
  value = aws_lambda_function.connectFunction
}
