resource "aws_apigatewayv2_api" "websocket" {
  name                       = "flowjoai-websocket"
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
}

resource "aws_apigatewayv2_route" "connectRoute" {
  api_id    = aws_apigatewayv2_api.websocket.id
  route_key = "$connect"
}

resource "aws_apigatewayv2_route" "disconnectRoute" {
  api_id    = aws_apigatewayv2_api.websocket.id
  route_key = "$disconnect"
}

resource "aws_apigatewayv2_route" "createEndpointRoute" {
  api_id    = aws_apigatewayv2_api.websocket.id
  route_key = "createEndpoint"
}

resource "aws_apigatewayv2_route" "predictRoute" {
  api_id    = aws_apigatewayv2_api.websocket.id
  route_key = "predict"
}

resource "aws_apigatewayv2_route" "startTrainingJobRoute" {
  api_id    = aws_apigatewayv2_api.websocket.id
  route_key = "startTrainingJob"
}

resource "aws_apigatewayv2_route" "updateModelRoute" {
  api_id    = aws_apigatewayv2_api.websocket.id
  route_key = "updateModel"
}

resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.websocket.id
  route_key = "$default"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"
  assume_role_policy = templatefile("../Lambda/lambda-base-policy.tpl.txt", {})
}

resource "aws_lambda_function" "connectFunction" {
  filename      = "../Lambda/flowjoai-client-connect.zip"
  function_name = "client-connect"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.handler"
  runtime       = "nodejs12.x"
}

resource "aws_apigatewayv2_integration" "connectIntegration" {
  api_id           = aws_apigatewayv2_api.websocket.id
  integration_type = "AWS"

  connection_type           = "INTERNET"
  content_handling_strategy = "CONVERT_TO_TEXT"
  description               = "function that runs upon client connection"
  integration_method        = "POST"
  integration_uri           = aws_lambda_function.connectFunction.invoke_arn
  passthrough_behavior      = "WHEN_NO_MATCH"
}