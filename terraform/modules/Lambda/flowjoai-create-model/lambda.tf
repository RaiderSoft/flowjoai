resource "aws_iam_role" "flowjoai-client-create-model-lambda-role" {
  name               = "${var.app_name}-${terraform.workspace}-client-create-model-lambda-role"
  assume_role_policy = file("${path.module}/iam/lambda_assume_policy.json")
}

resource "aws_iam_role_policy" "flowjoai-client-create-model-lambda-policy" {
  name   = "${var.app_name}-${terraform.workspace}-client-create-model-lambda-policy"
  role   = aws_iam_role.flowjoai-client-create-model-lambda-role.id
  policy = file("${path.module}/iam/lambda_policy.json")
}

data "archive_file" "createModelFunction" {
  type        = "zip"
  source_file = "${path.module}/exports.js"
  output_path = "${path.module}/exports.js.zip"
}

resource "aws_lambda_function" "createModelFunction" {
  filename         = data.archive_file.createModelFunction.output_path
  function_name    = "${var.app_name}-client-create-model-${terraform.workspace}"
  role             = aws_iam_role.flowjoai-client-create-model-lambda-role.arn
  handler          = "exports.handler"
  runtime          = "nodejs12.x"
  source_code_hash = data.archive_file.createModelFunction.output_base64sha256
}

output "createModelFunction" {
  value = aws_lambda_function.createModelFunction
}
