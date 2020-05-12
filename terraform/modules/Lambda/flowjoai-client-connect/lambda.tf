resource "aws_iam_role" "flowjoai-client-disconnect-role" {
  name = "flowjoai-client-disconnect-role"
  assume_role_policy = file("../terraform/modules/Lambda/flowjoai-client-connect/iam/lambda_assume_policy.json")
}

resource "aws_iam_role_policy" "flowjoai-client-disconnect-role-policy" {
  name = "flowjoai-client-disconnect-role-policy"
  role = aws_iam_role.flowjoai-client-disconnect-role.id
  policy = file("../terraform/modules/Lambda/flowjoai-client-connect/iam/lambda_policy.json")
}

resource "aws_lambda_function" "connectFunction" {
  filename         = "../terraform/modules/Lambda/flowjoai-client-connect/exports.js.zip"
  function_name    = "client-connect"
  role             = aws_iam_role.flowjoai-client-disconnect-role.arn
  handler          = "exports.handler"
  runtime          = "nodejs12.x"
  source_code_hash = filebase64sha256("../terraform/modules/Lambda/flowjoai-client-connect/exports.js.zip")
}

output "connectFunction" {
  value = aws_lambda_function.connectFunction
}