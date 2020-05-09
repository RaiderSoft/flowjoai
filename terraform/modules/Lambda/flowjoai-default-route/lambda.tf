resource "aws_iam_role" "iam_for_lambda" {
  name = "default_lambda_role"
  assume_role_policy = file("../terraform/modules/Lambda/flowjoai-default-route/iam/lambda_assume_policy.json")
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "default_lambda_policy"
  role = aws_iam_role.iam_for_lambda.id
  policy = file("../terraform/modules/Lambda/flowjoai-default-route/iam/lambda_policy.json")
}

resource "aws_lambda_function" "defaultRoute" {
  filename         = "../terraform/modules/Lambda/flowjoai-default-route/exports.js.zip"
  function_name    = "default-route"
  role             = aws_iam_role.flowjoai_default_route_iam_role.arn
  handler          = "exports.handler"
  runtime          = "nodejs12.x"
  source_code_hash = filebase64sha256("../terraform/modules/Lambda/flowjoai-default-route/exports.js.zip")
}

output "defaultRoute" {
  value = aws_lambda_function.defaultRoute
}