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

resource "aws_apigatewayv2_integration" "connectIntegration" {
  api_id             = aws_apigatewayv2_api.websocket.id
  integration_type   = "AWS_PROXY"
  description        = "Connect Integration"
  integration_uri    = module.flowjoai_client_connect.connectFunction.invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "connectRoute" {
  api_id         = aws_apigatewayv2_api.websocket.id
  route_key      = "$connect"
  operation_name = "connectRoute"
  target         = "integrations/${aws_apigatewayv2_integration.connectIntegration.id}"

}

