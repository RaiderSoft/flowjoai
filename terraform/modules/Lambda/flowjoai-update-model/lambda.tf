resource "aws_iam_role" "flowjoai-update-model-lambda-role" {
  name = "flowjoai-update-model-lambda-role"
  assume_role_policy = file("../terraform/modules/Lambda/flowjoai-update-model/iam/lambda_assume_policy.json")
}

resource "aws_iam_role_policy" "flowjoai-update-model-lambda-policy" {
  name = "flowjoai-update-model-lambda-policy"
  role = aws_iam_role.flowjoai-update-model-lambda-role.id
  policy = file("../terraform/modules/Lambda/flowjoai-update-model/iam/lambda_policy.json")
}

resource "aws_lambda_function" "updateModelFunction" {
  filename         = "../terraform/modules/Lambda/flowjoai-update-model/exports.js.zip"
  function_name    = "update-model"
  role             = aws_iam_role.flowjoai-update-model-lambda-role.arn
  handler          = "exports.handler"
  runtime          = "nodejs12.x"
  source_code_hash = filebase64sha256("../terraform/modules/Lambda/flowjoai-update-model/exports.js.zip")
}

output "updateModelFunction" {
  value = aws_lambda_function.updateModelFunction
}