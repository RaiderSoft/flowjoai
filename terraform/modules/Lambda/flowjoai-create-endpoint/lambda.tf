resource "aws_iam_role" "iam_for_lambda" {
  name = "flowjoai-create-endpoint-lambda-role"
  assume_role_policy = file("../terraform/modules/Lambda/flowjoai-create-endpoint/iam/lambda_assume_policy.json")
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "flowjoai-create-endpoint-lambda-policy"
  role = aws_iam_role.iam_for_lambda.id
  policy = file("../terraform/modules/Lambda/flowjoai-create-endpoint/iam/lambda_policy.json")
}

resource "aws_lambda_function" "createEndpointFunction" {
  filename         = "../Lambda/flowjoai-create-endpoint/exports.js.zip"
  function_name    = "create-endpoint"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "exports.handler"
  runtime          = "nodejs12.x"
  source_code_hash = filebase64sha256("../terraform/modules/Lambda/flowjoai-create-endpoint/exports.js.zip")
}

output "createEndpointFunction" {
  value = aws_lambda_function.createEndpointFunction
}