resource "aws_iam_role" "flowjoai-client-onmessage-lambda-role" {
  name = "flowjoai-client-onmessage-lambda-role"
  assume_role_policy = file("../terraform/modules/Lambda/flowjoai-client-onmessage/iam/lambda_assume_policy.json")
}

resource "aws_iam_role_policy" "flowjoai-client-onmessage-lambda-policy" {
  name = "flowjoai-client-onmessage-lambda-policy"
  role = aws_iam_role.iam_for_lambda.id
  policy = file("../terraform/modules/Lambda/flowjoai-client-onmessage/iam/lambda_policy.json")
}

resource "aws_lambda_function" "onMessageFunction" {
  filename         = "../Lambda/flowjoai-client-onmessage/exports.js.zip"
  function_name    = "client-onmessage"
  role             = aws_iam_role.flowjoai-client-onmessage-lambda-role.arn
  handler          = "exports.handler"
  runtime          = "nodejs12.x"
  source_code_hash = filebase64sha256("../terraform/modules/Lambda/flowjoai-client-onmessage/exports.js.zip")
}

output "onMessageFunction" {
  value = aws_lambda_function.onMessageFunction
}