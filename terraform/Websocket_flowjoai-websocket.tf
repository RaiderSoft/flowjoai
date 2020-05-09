provider "aws" {
    profile = "default"
    region = "us-east-2"
}

module "flowjoai_client_connect" {
  source = "../Lambda/flowjoai-client-connect"
}

resource "aws_apigatewayv2_api" "websocket" {
  name                       = "flowjoai-websocket-v1"
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

resource "aws_apigatewayv2_integration" "connectRoute" {
  api_id           = aws_apigatewayv2_api.websocket.id
  integration_type = "AWS"


  connection_type           = "INTERNET"
  content_handling_strategy = "CONVERT_TO_TEXT"
  description               = "function that runs upon client connection"
  integration_method        = "POST"
  integration_uri           = module.flowjoai_client_connect.connectFunction.invoke_arn
  passthrough_behavior      = "WHEN_NO_MATCH"
}
