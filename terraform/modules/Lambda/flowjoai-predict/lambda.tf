resource "aws_iam_role" "flowjoai-predict-lambda-role" {
  name = "flowjoai-predict-lambda-role"
  assume_role_policy = file("iam/lambda_assume_policy.json")
}

resource "aws_iam_role_policy" "flowjoai-predict-lambda-policy" {
  name = "flowjoai-predict-lambda-policy"
  role = aws_iam_role.flowjoai-predict-lambda-role.id
  policy = file("lambda_policy.json")
}

resource "aws_lambda_function" "predictFunction" {
  filename         = "exports.js.zip"
  function_name    = "predict"
  role             = aws_iam_role.flowjoai-predict-lambda-role.arn
  handler          = "exports.handler"
  runtime          = "nodejs12.x"
  source_code_hash = filebase64sha256("exports.js.zip")
}

output "predictFunction" {
  value = aws_lambda_function.predictFunction
}