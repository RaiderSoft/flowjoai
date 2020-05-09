#
# Webocket server connecting FlowJoAI services to Lambdas
#
###############################################################################################
######## ------ websocket setup ------ ######## START

resource "aws_apigatewayv2_api" "websocket" {
  name                       = "flowjoai-websocket-v1"
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
}

output "flowjoai-websocket" {
  value = aws_apigatewayv2_api.websocket
}

######## ------ websocket setup ------ ######## END

###############################################################################################


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

###############################################################################################

######## ------ updateModelRoute ------ ######## START

resource "aws_apigatewayv2_route" "updateModelRoute" {
  api_id    = aws_apigatewayv2_api.websocket.id
  route_key = "updateModel"
}
######## ------ updateModelRoute ------ ######## END

###############################################################################################

######## ------ defaultRoute ------ ######## START

module "flowjoai_default_route" {
  source = "../../Lambda/flowjoai-default-route"
}

resource "aws_apigatewayv2_integration" "defaultIntegration" {
  api_id             = aws_apigatewayv2_api.websocket.id
  integration_type   = "AWS_PROXY"
  description        = "Connect Integration"
  integration_uri    = module.flowjoai_default_route.defaultRoute.invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "default" {
  api_id         = aws_apigatewayv2_api.websocket.id
  route_key      = "$default"
  operation_name = "connectRoute"
  target         = "integrations/${aws_apigatewayv2_integration.defaultIntegration.id}"
}
######## ------ defaultRoute ------ ######## END

###############################################################################################

######## ------ onConnect ------ ######## START

module "flowjoai_client_connect" {
  source = "../../Lambda/flowjoai-client-connect"
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

######## ------ onConnect ------ ######## END
