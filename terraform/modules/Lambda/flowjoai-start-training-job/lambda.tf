resource "aws_iam_role" "flowjoai-start-training-job-lambda-role" {
  name = "flowjoai-start-training-job-lambda-role"
  assume_role_policy = file("../terraform/modules/Lambda/flowjoai-start-training-job/iam/lambda_assume_policy.json")
}

resource "aws_iam_role_policy" "flowjoai-start-training-job-lambda-policy" {
  name = "flowjoai-start-training-job-lambda-policy"
  role = aws_iam_role.flowjoai-start-training-job-lambda-role.id
  policy = file("../terraform/modules/Lambda/flowjoai-start-training-job/iam/lambda_policy.json")
}

resource "aws_lambda_function" "startTrainingJobFunction" {
  filename         = "../terraform/modules/Lambda/flowjoai-start-training-job/exports.js.zip"
  function_name    = "start-training-job"
  role             = aws_iam_role.flowjoai-start-training-job-lambda-role.arn
  handler          = "exports.handler"
  runtime          = "nodejs12.x"
  source_code_hash = filebase64sha256("../terraform/modules/Lambda/flowjoai-start-training-job/exports.js.zip")
}

output "startTrainingJobFunction" {
  value = aws_lambda_function.startTrainingJobFunction
}