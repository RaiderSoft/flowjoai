resource "aws_iam_role" "flowjoai-client-disconnect-lambda-role" {
  name = "${var.app_name}-${terraform.workspace}-client-disconnect-lambda-role"
  assume_role_policy = file("${path.module}/iam/lambda_assume_policy.json")
}

resource "aws_iam_role_policy" "flowjoai-client-disconnect-lambda-policy" {
  name = "${var.app_name}-${terraform.workspace}-client-disconnect-lambda-policy"
  role = aws_iam_role.flowjoai-client-disconnect-lambda-role.id
  policy = file("${path.module}/iam/lambda_policy.json")
}

data "archive_file" "disconnectFunction" {
  type        = "zip"
  source_file = "${path.module}/exports.js"
  output_path = "${path.module}/exports.js.zip"
}

resource "aws_lambda_function" "disconnectFunction" {
  filename         = data.archive_file.disconnectFunction.output_path
  function_name    = "${var.app_name}-client-disconnect-${terraform.workspace}"
  role             = aws_iam_role.flowjoai-client-disconnect-lambda-role.arn
  handler          = "exports.handler"
  runtime          = "nodejs12.x"
  source_code_hash = data.archive_file.disconnectFunction.output_base64sha256
}

output "disconnectFunction" {
  value = aws_lambda_function.disconnectFunction
}