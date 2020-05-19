resource "aws_iam_role" "flowjoai-default-route-lambda-role" {
  name = "flowjoai-default-route-lambda-role"
  assume_role_policy = file("iam/lambda_assume_policy.json")
}

resource "aws_iam_role_policy" "flowjoai-default-route-lambda-policy" {
  name = "flowjoai-default-route-lambda-policy"
  role = aws_iam_role.flowjoai-default-route-lambda-role.id
  policy = file("iam/lambda_policy.json")
}

resource "aws_lambda_function" "defaultRoute" {
  filename         = "exports.js.zip"
  function_name    = "default-route"
  role             = aws_iam_role.flowjoai-default-route-lambda-role.arn
  handler          = "exports.handler"
  runtime          = "nodejs12.x"
  source_code_hash = filebase64sha256("exports.js.zip")
}

output "defaultRoute" {
  value = aws_lambda_function.defaultRoute
}