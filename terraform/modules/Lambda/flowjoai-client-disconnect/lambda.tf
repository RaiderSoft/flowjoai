resource "aws_iam_role" "flowjoai-client-disconnect-lambda-role" {
  name = "flowjoai-client-disconnect-lambda-role"
  assume_role_policy = file("iam/lambda_assume_policy.json")
}

resource "aws_iam_role_policy" "flowjoai-client-disconnect-lambda-policy" {
  name = "flowjoai-client-disconnect-lambda-policy"
  role = aws_iam_role.flowjoai-client-disconnect-lambda-role.id
  policy = file("iam/lambda_policy.json")
}

resource "aws_lambda_function" "disconnectFunction" {
  filename         = "exports.js.zip"
  function_name    = "client-disconnect"
  role             = aws_iam_role.flowjoai-client-disconnect-lambda-role.arn
  handler          = "exports.handler"
  runtime          = "nodejs12.x"
  source_code_hash = filebase64sha256("exports.js.zip")
}

output "disconnectFunction" {
  value = aws_lambda_function.disconnectFunction
}