resource "aws_iam_role" "flowjoai-create-model-lambda-role" {
  name = "flowjoai-create-model-lambda-role"
  assume_role_policy = file("iam/lambda_assume_policy.json")
}

resource "aws_iam_role_policy" "flowjoai-create-model-lambda-policy" {
  name = "flowjoai-create-model-lambda-policy"
  role = aws_iam_role.flowjoai-create-model-lambda-role.id
  policy = file("iam/lambda_policy.json")
}

resource "aws_lambda_function" "createModelFunction" {
  filename         = "exports.js.zip"
  function_name    = "create-model"
  role             = aws_iam_role.flowjoai-create-model-lambda-role.arn
  handler          = "exports.handler"
  runtime          = "nodejs12.x"
  source_code_hash = filebase64sha256("exports.js.zip")
}

output "createModelFunction" {
  value = aws_lambda_function.createModelFunction
}