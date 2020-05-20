#
# Webocket server connecting FlowJoAI services to Lambdas
#
###############################################################################################
######## ------ websocket setup ------ ######## START

resource "aws_apigatewayv2_api" "websocket" {
  name                       = "${var.app_name}-websocket-v1-${terraform.workspace}"
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
}

output "flowjoai-websocket" {
  value = aws_apigatewayv2_api.websocket
}

######## ------ websocket setup ------ ######## END

###############################################################################################

######## ------ defaultRoute ------ ######## START

module "flowjoai_default_route" {
  source = "../../Lambda/flowjoai-default-route"
  app_name = var.app_name
}

resource "aws_apigatewayv2_integration" "defaultIntegration" {
  api_id             = aws_apigatewayv2_api.websocket.id
  integration_type   = "AWS_PROXY"
  description        = "Connect Integration"
  integration_uri    = module.flowjoai_default_route.defaultRoute.invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "defaultRoute" {
  api_id         = aws_apigatewayv2_api.websocket.id
  route_key      = "$default"
  operation_name = "connectRoute"
  target         = "integrations/${aws_apigatewayv2_integration.defaultIntegration.id}"
}

resource "aws_apigatewayv2_integration_response" "defaultIntegrationResponse" {
  api_id                   = aws_apigatewayv2_api.websocket.id
  integration_id           = aws_apigatewayv2_integration.defaultIntegration.id
  integration_response_key = "/200/"
}

resource "aws_apigatewayv2_route_response" "defaultRouteResponse" {
  api_id             = aws_apigatewayv2_api.websocket.id
  route_id           = aws_apigatewayv2_route.defaultRoute.id
  route_response_key = "$default"
}


######## ------ defaultRoute ------ ######## END

###############################################################################################

######## ------ onConnect ------ ######## START

module "flowjoai_client_connect" {
  source = "../../Lambda/flowjoai-client-connect"
  app_name = var.app_name
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

resource "aws_apigatewayv2_integration_response" "connectIntegrationResponse" {
  api_id                   = aws_apigatewayv2_api.websocket.id
  integration_id           = aws_apigatewayv2_integration.connectIntegration.id
  integration_response_key = "/200/"
}

resource "aws_apigatewayv2_route_response" "connectRouteResponse" {
  api_id             = aws_apigatewayv2_api.websocket.id
  route_id           = aws_apigatewayv2_route.connectRoute.id
  route_response_key = "$default"
}

######## ------ onConnect ------ ######## END

###############################################################################################

######## ------ onDisconnect ------ ######## START

module "flowjoai_client_disconnect" {
  source = "../../Lambda/flowjoai-client-disconnect"
  app_name = var.app_name
}

resource "aws_apigatewayv2_integration" "disconnectIntegration" {
  api_id             = aws_apigatewayv2_api.websocket.id
  integration_type   = "AWS_PROXY"
  description        = "Disconnect Integration"
  integration_uri    = module.flowjoai_client_disconnect.disconnectFunction.invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "disconnectRoute" {
  api_id         = aws_apigatewayv2_api.websocket.id
  route_key      = "$disconnect"
  operation_name = "disconnectRoute"
  target         = "integrations/${aws_apigatewayv2_integration.disconnectIntegration.id}"
}

resource "aws_apigatewayv2_integration_response" "disconnectIntegrationResponse" {
  api_id                   = aws_apigatewayv2_api.websocket.id
  integration_id           = aws_apigatewayv2_integration.disconnectIntegration.id
  integration_response_key = "/200/"
}

resource "aws_apigatewayv2_route_response" "disconnectRouteResponse" {
  api_id             = aws_apigatewayv2_api.websocket.id
  route_id           = aws_apigatewayv2_route.disconnectRoute.id
  route_response_key = "$default"
}

######## ------ onDisconnect ------ ######## END

###############################################################################################

######## ------ onMessage ------ ######## START

module "flowjoai_client_onmessage" {
  source = "../../Lambda/flowjoai-client-onmessage"
  app_name = var.app_name
}

resource "aws_apigatewayv2_integration" "onMessageIntegration" {
  api_id             = aws_apigatewayv2_api.websocket.id
  integration_type   = "AWS_PROXY"
  description        = "OnMessage Integration"
  integration_uri    = module.flowjoai_client_onmessage.onMessageFunction.invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "onMessageRoute" {
  api_id         = aws_apigatewayv2_api.websocket.id
  route_key      = "onMessage"
  operation_name = "onMessageRoute"
  target         = "integrations/${aws_apigatewayv2_integration.onMessageIntegration.id}"
}

resource "aws_apigatewayv2_integration_response" "onMessageIntegrationResponse" {
  api_id                   = aws_apigatewayv2_api.websocket.id
  integration_id           = aws_apigatewayv2_integration.onMessageIntegration.id
  integration_response_key = "/200/"
}

resource "aws_apigatewayv2_route_response" "onMessageRouteResponse" {
  api_id             = aws_apigatewayv2_api.websocket.id
  route_id           = aws_apigatewayv2_route.onMessageRoute.id
  route_response_key = "$default"
}

######## ------ onMessage ------ ######## END

###############################################################################################

######## ------ createEndpoint ------ ######## START

module "flowjoai_client_create_endpoint" {
  source = "../../Lambda/flowjoai-create-endpoint"
  app_name = var.app_name
}

resource "aws_apigatewayv2_integration" "createEndpointIntegration" {
  api_id             = aws_apigatewayv2_api.websocket.id
  integration_type   = "AWS_PROXY"
  description        = "Create Endpoint Integration"
  integration_uri    = module.flowjoai_client_create_endpoint.createEndpointFunction.invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "createEndpointRoute" {
  api_id         = aws_apigatewayv2_api.websocket.id
  route_key      = "createEndpoint"
  operation_name = "createEndpointRoute"
  target         = "integrations/${aws_apigatewayv2_integration.createEndpointIntegration.id}"
}

resource "aws_apigatewayv2_integration_response" "createEndpointIntegrationResponse" {
  api_id                   = aws_apigatewayv2_api.websocket.id
  integration_id           = aws_apigatewayv2_integration.createEndpointIntegration.id
  integration_response_key = "/200/"
}

resource "aws_apigatewayv2_route_response" "createEnpointRouteResponse" {
  api_id             = aws_apigatewayv2_api.websocket.id
  route_id           = aws_apigatewayv2_route.createEndpointRoute.id
  route_response_key = "$default"
}

######## ------ createEndpoint ------ ######## END

###############################################################################################

######## ------ createModel ------ ######## START

module "flowjoai_client_create_model" {
  source = "../../Lambda/flowjoai-create-model"
  app_name = var.app_name
}

resource "aws_apigatewayv2_integration" "createModelIntegration" {
  api_id             = aws_apigatewayv2_api.websocket.id
  integration_type   = "AWS_PROXY"
  description        = "Create Model Integration"
  integration_uri    = module.flowjoai_client_create_model.createModelFunction.invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "createModelRoute" {
  api_id         = aws_apigatewayv2_api.websocket.id
  route_key      = "createModel"
  operation_name = "createModelRoute"
  target         = "integrations/${aws_apigatewayv2_integration.createModelIntegration.id}"
}

resource "aws_apigatewayv2_integration_response" "createModelIntegrationResponse" {
  api_id                   = aws_apigatewayv2_api.websocket.id
  integration_id           = aws_apigatewayv2_integration.createModelIntegration.id
  integration_response_key = "/200/"
}

resource "aws_apigatewayv2_route_response" "createModelRouteResponse" {
  api_id             = aws_apigatewayv2_api.websocket.id
  route_id           = aws_apigatewayv2_route.createModelRoute.id
  route_response_key = "$default"
}

######## ------ createModel ------ ######## END

###############################################################################################

######## ------ modelsStream ------ ######## START

module "flowjoai_models_stream" {
  source = "../../Lambda/flowjoai-models-stream"
  app_name = var.app_name
}

resource "aws_apigatewayv2_integration" "modelsStreamIntegration" {
  api_id             = aws_apigatewayv2_api.websocket.id
  integration_type   = "AWS_PROXY"
  description        = "Model Stream Integration"
  integration_uri    = module.flowjoai_models_stream.modelsStreamFunction.invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "modelsStreamRoute" {
  api_id         = aws_apigatewayv2_api.websocket.id
  route_key      = "modelsStream"
  operation_name = "modelsStreamRoute"
  target         = "integrations/${aws_apigatewayv2_integration.modelsStreamIntegration.id}"
}

resource "aws_apigatewayv2_integration_response" "modelStreamIntegrationResponse" {
  api_id                   = aws_apigatewayv2_api.websocket.id
  integration_id           = aws_apigatewayv2_integration.modelsStreamIntegration.id
  integration_response_key = "/200/"
}

resource "aws_apigatewayv2_route_response" "modelStreamRouteResponse" {
  api_id             = aws_apigatewayv2_api.websocket.id
  route_id           = aws_apigatewayv2_route.modelsStreamRoute.id
  route_response_key = "$default"
}

######## ------ modelsStream ------ ######## END

###############################################################################################

######## ------ predict ------ ######## START

module "flowjoai_predict" {
  source = "../../Lambda/flowjoai-predict"
  app_name = var.app_name
}

resource "aws_apigatewayv2_integration" "predictIntegration" {
  api_id             = aws_apigatewayv2_api.websocket.id
  integration_type   = "AWS_PROXY"
  description        = "Predict Integration"
  integration_uri    = module.flowjoai_predict.predictFunction.invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "predictRoute" {
  api_id         = aws_apigatewayv2_api.websocket.id
  route_key      = "predict"
  operation_name = "predictRoute"
  target         = "integrations/${aws_apigatewayv2_integration.predictIntegration.id}"
}

resource "aws_apigatewayv2_integration_response" "predictIntegrationResponse" {
  api_id                   = aws_apigatewayv2_api.websocket.id
  integration_id           = aws_apigatewayv2_integration.predictIntegration.id
  integration_response_key = "/200/"
}

resource "aws_apigatewayv2_route_response" "predictRouteResponse" {
  api_id             = aws_apigatewayv2_api.websocket.id
  route_id           = aws_apigatewayv2_route.predictRoute.id
  route_response_key = "$default"
}

######## ------ predict ------ ######## END

###############################################################################################

######## ------ startTrainingJob ------ ######## START

module "flowjoai_start_training_job" {
  source = "../../Lambda/flowjoai-start-training-job"
  app_name = var.app_name
}

resource "aws_apigatewayv2_integration" "startTrainingJobIntegration" {
  api_id             = aws_apigatewayv2_api.websocket.id
  integration_type   = "AWS_PROXY"
  description        = "Start Training Job Integration"
  integration_uri    = module.flowjoai_start_training_job.startTrainingJobFunction.invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "startTrainingJobRoute" {
  api_id         = aws_apigatewayv2_api.websocket.id
  route_key      = "startTrainingJob"
  operation_name = "startTrainingJobRoute"
  target         = "integrations/${aws_apigatewayv2_integration.startTrainingJobIntegration.id}"
}

resource "aws_apigatewayv2_integration_response" "startTrainingJobIntegrationResponse" {
  api_id                   = aws_apigatewayv2_api.websocket.id
  integration_id           = aws_apigatewayv2_integration.startTrainingJobIntegration.id
  integration_response_key = "/200/"
}

resource "aws_apigatewayv2_route_response" "startTrainingJobRouteResponse" {
  api_id             = aws_apigatewayv2_api.websocket.id
  route_id           = aws_apigatewayv2_route.startTrainingJobRoute.id
  route_response_key = "$default"
}

######## ------ startTrainingJob ------ ######## END

###############################################################################################

######## ------ updateModelRoute ------ ######## START

module "flowjoai_update_model" {
  source = "../../Lambda/flowjoai-update-model"
  app_name = var.app_name
}

resource "aws_apigatewayv2_integration" "updateModelIntegration" {
  api_id             = aws_apigatewayv2_api.websocket.id
  integration_type   = "AWS_PROXY"
  description        = "Update Model Integration"
  integration_uri    = module.flowjoai_update_model.updateModelFunction.invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "updateModelRoute" {
  api_id         = aws_apigatewayv2_api.websocket.id
  route_key      = "updateModel"
  operation_name = "updateModelRoute"
  target         = "integrations/${aws_apigatewayv2_integration.updateModelIntegration.id}"
}

resource "aws_apigatewayv2_integration_response" "updateModelIntegrationResponse" {
  api_id                   = aws_apigatewayv2_api.websocket.id
  integration_id           = aws_apigatewayv2_integration.updateModelIntegration.id
  integration_response_key = "/200/"
}

resource "aws_apigatewayv2_route_response" "updateeModelRouteResponse" {
  api_id             = aws_apigatewayv2_api.websocket.id
  route_id           = aws_apigatewayv2_route.updateModelRoute.id
  route_response_key = "$default"
}
######## ------ updateModelRoute ------ ######## END

###############################################################################################
