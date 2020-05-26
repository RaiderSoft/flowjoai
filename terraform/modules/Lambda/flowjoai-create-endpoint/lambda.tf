resource "aws_iam_role" "flowjoai-client-create-endpoint-lambda-role" {
  name               = "${var.app_name}-${terraform.workspace}-client-create-endpoint-lambda-role"
  assume_role_policy = file("${path.module}/iam/lambda_assume_policy.json")
}

resource "aws_iam_role_policy" "flowjoai-client-create-endpoint-lambda-policy" {
  name   = "${var.app_name}-${terraform.workspace}-client-create-endpoint-lambda-policy"
  role   = aws_iam_role.flowjoai-client-create-endpoint-lambda-role.id
  policy = file("${path.module}/iam/lambda_policy.json")
}

data "archive_file" "create-endpointFunction" {
  type        = "zip"
  source_file = "${path.module}/exports.js"
  output_path = "${path.module}/exports.js.zip"
}

resource "aws_lambda_function" "createEndpointFunction" {
  filename         = data.archive_file.createEndpointFunction.output_path
  function_name    = "${var.app_name}-client-create-endpoint-${terraform.workspace}"
  role             = aws_iam_role.flowjoai-client-create-endpoint-lambda-role.arn
  handler          = "exports.handler"
  runtime          = "nodejs12.x"
  source_code_hash = data.archive_file.createEndpointFunction.output_base64sha256
}

output "createEndpointFunction" {
  value = aws_lambda_function.create-endpointFunction
}
