resource "aws_iam_role" "flowjoai-client-connect-lambda-role" {
  # scope with app name and workspace
  name = "${var.app_name}-${terraform.workspace}-client-connect-lambda-role"
  # path.module prevents scoping issues
  assume_role_policy = file("${path.module}/iam/lambda_assume_policy.json")
}

resource "aws_iam_role_policy" "flowjoai-client-connect-lambda-policy" {
  # scope with app name and workspace
  name = "${var.app_name}-${terraform.workspace}-client-connect-lambda-policy"
  role = aws_iam_role.flowjoai-client-connect-lambda-role.id
  # path.module prevents scoping issues
  policy = file("${path.module}/iam/lambda_policy.json")
}

# This ensures the latest code is always zipped up and uploaded to lambda
# without requiring intervention
data "archive_file" "connectFunction" {
  type        = "zip"
  source_file = "${path.module}/exports.js"
  output_path = "${path.module}/exports.js.zip"
}

resource "aws_lambda_function" "connectFunction" {
  filename         = data.archive_file.connectFunction.output_path
  # better to have a name and the name of the current workspace so
  # more than one build of this could be made in the same acct & region
  function_name    = "${var.app_name}-client-connect-${terraform.workspace}"
  role             = aws_iam_role.flowjoai-client-connect-lambda-role.arn
  handler          = "exports.handler"
  runtime          = "nodejs12.x"
  source_code_hash = data.archive_file.connectFunction.output_base64sha256
}

output "connectFunction" {
  value = aws_lambda_function.connectFunction
}
