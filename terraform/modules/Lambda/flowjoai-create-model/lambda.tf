resource "aws_iam_role" "iam_for_lambda" {
  name = "flowjoai-create-model-lambda-role"
  assume_role_policy = file("../terraform/modules/Lambda/flowjoai-create-model/iam/lambda_assume_policy.json")
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "flowjoai-create-model-lambda-policy"
  role = aws_iam_role.iam_for_lambda.id
  policy = file("../terraform/modules/Lambda/flowjoai-create-model/iam/lambda_policy.json")
}

resource "aws_lambda_function" "createModelFunction" {
  filename         = "../Lambda/flowjoai-create-model/exports.js.zip"
  function_name    = "create-model"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "exports.handler"
  runtime          = "nodejs12.x"
  source_code_hash = filebase64sha256("../terraform/modules/Lambda/flowjoai-create-model/exports.js.zip")
}

output "createModelFunction" {
  value = aws_lambda_function.createModelFunction
}