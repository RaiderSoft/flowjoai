resource "aws_iam_role" "flowjoai-start-training-job-lambda-role" {
  name = "${var.app_name}-${terraform.workspace}-start-training-job-lambda-role"
  assume_role_policy = file("${path.module}/iam/lambda_assume_policy.json")
}

resource "aws_iam_role_policy" "flowjoai-start-training-job-lambda-policy" {
  name = "${var.app_name}-${terraform.workspace}-start-training-job-lambda-policy"
  role = aws_iam_role.flowjoai-start-training-job-lambda-role.id
  policy = file("${path.module}/iam/lambda_policy.json")
}

data "archive_file" "startTrainingJobFunction" {
  type        = "zip"
  source_file = "${path.module}/exports.js"
  output_path = "${path.module}/exports.js.zip"
}


resource "aws_lambda_function" "startTrainingJobFunction" {
  filename         = data.archive_file.startTrainingJobFunction.output_path
  function_name    = "${var.app_name}-start-training-job-${terraform.workspace}"
  role             = aws_iam_role.flowjoai-start-training-job-lambda-role.arn
  handler          = "exports.handler"
  runtime          = "nodejs12.x"
  source_code_hash = data.archive_file.startTrainingJobFunction.output_base64sha256
}

output "startTrainingJobFunction" {
  value = aws_lambda_function.startTrainingJobFunction
}