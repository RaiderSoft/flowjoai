resource "aws_iam_role" "iam_for_lambda" {
  name = "lambda_role"
  assume_role_policy = file("../terraform/modules/Lambda/flowjoai-client-connect/iam/lambda_assume_policy.json")
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = aws_iam_role.iam_for_lambda.id
  policy = file("../terraform/modules/Lambda/flowjoai-client-connect/iam/lambda_policy.json")
}

resource "aws_lambda_function" "connectFunction" {
  filename         = "../terraform/modules/Lambda/flowjoai-client-connect/exports.js.zip"
  function_name    = "client-connect"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "exports.handler"
  runtime          = "nodejs12.x"
  source_code_hash = filebase64sha256("../terraform/modules/Lambda/flowjoai-client-connect/exports.js.zip")
}

output "connectFunction" {
  value = aws_lambda_function.connectFunction
}