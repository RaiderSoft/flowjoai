resource "aws_iam_role" "flowjoai-create-endpoint-lambda-role" {
  name = "flowjoai-create-endpoint-lambda-role"
  assume_role_policy = file("iam/lambda_assume_policy.json")
}

resource "aws_iam_role_policy" "flowjoai-create-endpoint-lambda-policy" {
  name = "flowjoai-create-endpoint-lambda-policy"
  role = aws_iam_role.flowjoai-create-endpoint-lambda-role.id
  policy = file("iam/lambda_policy.json")
}

resource "aws_lambda_function" "createEndpointFunction" {
  filename         = "exports.js.zip"
  function_name    = "create-endpoint"
  role             = aws_iam_role.flowjoai-create-endpoint-lambda-role.arn
  handler          = "exports.handler"
  runtime          = "nodejs12.x"
  source_code_hash = filebase64sha256("exports.js.zip")
}

output "createEndpointFunction" {
  value = aws_lambda_function.createEndpointFunction
}