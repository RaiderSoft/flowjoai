resource "aws_iam_role" "flowjoai-client-disconnect-iam-role" {
  name = "flowjoai-client-disconnect-iam-role"
  assume_role_policy = file("../terraform/modules/Lambda/flowjoai-client-disconnect/iam/lambda_assume_policy.json")
}

resource "aws_iam_role_policy" "flowjoai-client-disconnect-lambda-policy" {
  name = "flowjoai-client-disconnect-lambda-policy"
  role = aws_iam_role.flowjoai-client-disconnect-iam-role.id
  policy = file("../terraform/modules/Lambda/flowjoai-client-disconnect/iam/lambda_policy.json")
}

resource "aws_lambda_function" "disconnectFunction" {
  filename         = "../terraform/modules/Lambda/flowjoai-client-disconnect/exports.js.zip"
  function_name    = "client-disconnect"
  role             = aws_iam_role.flowjoai-client-disconnect-iam-role.arn
  handler          = "exports.handler"
  runtime          = "nodejs12.x"
  source_code_hash = filebase64sha256("../terraform/modules/Lambda/flowjoai-client-disconnect/exports.js.zip")
}

output "disconnectFunction" {
  value = aws_lambda_function.disconnectFunction
}