resource "aws_iam_role" "iam_for_lambda" {
  name = "disconnect_lambda_role"
  assume_role_policy = file("./iam/lambda_assume_policy.json")
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "disconnect_lambda_policy"
  role = aws_iam_role.iam_for_lambda.id
  policy = file("./iam/lambda_policy.json")
}

resource "aws_lambda_function" "disconnectFunction" {
  filename         = "../Lambda/flowjoai-client-disconnect/exports.js.zip"
  function_name    = "client-disconnect"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "exports.handler"
  runtime          = "nodejs12.x"
  source_code_hash = filebase64sha256("./exports.js.zip")
}

output "disconnectFunction" {
  value = aws_lambda_function.disconnectFunction
}