resource "aws_iam_role" "flowjoai-models-stream-lambda-role" {
  name = "flowjoai-models-stream-lambda-role"
  assume_role_policy = file("iam/lambda_assume_policy.json")
}

resource "aws_iam_role_policy" "flowjoai-models-stream-lambda-policy" {
  name = "flowjoai-models-stream-lambda-policy"
  role = aws_iam_role.flowjoai-models-stream-lambda-role.id
  policy = file("iam/lambda_policy.json")
}

resource "aws_lambda_function" "modelsStreamFunction" {
  filename         = "exports.js.zip"
  function_name    = "models-stream"
  role             = aws_iam_role.flowjoai-models-stream-lambda-role.arn
  handler          = "exports.handler"
  runtime          = "nodejs12.x"
  source_code_hash = filebase64sha256("exports.js.zip")
}

output "modelsStreamFunction" {
  value = aws_lambda_function.modelsStreamFunction
}