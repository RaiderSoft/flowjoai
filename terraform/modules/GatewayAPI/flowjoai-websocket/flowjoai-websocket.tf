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

###############################################################################################

######## ------ onDisconnect ------ ######## START

module "flowjoai_client_disconnect" {
  source = "../../Lambda/flowjoai-client-disconnect"
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

######## ------ onDisconnect ------ ######## END

###############################################################################################

######## ------ onMessage ------ ######## START

module "flowjoai_client_onmessage" {
  source = "../../Lambda/flowjoai-client-onmessage"
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

######## ------ onMessage ------ ######## END

###############################################################################################

######## ------ createEndpoint ------ ######## START

module "flowjoai_client_create_endpoint" {
  source = "../../Lambda/flowjoai-create-endpoint"
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

######## ------ createEndpoint ------ ######## END

###############################################################################################

######## ------ createModel ------ ######## START

module "flowjoai_client_create_model" {
  source = "../../Lambda/flowjoai-create-model"
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

######## ------ createModel ------ ######## END

###############################################################################################

######## ------ modelsStream ------ ######## START

module "flowjoai_models_stream" {
  source = "../../Lambda/flowjoai-models-stream"
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

######## ------ modelsStream ------ ######## END

###############################################################################################

######## ------ predict ------ ######## START

module "flowjoai_predict" {
  source = "../../Lambda/flowjoai-predict"
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

######## ------ predict ------ ######## END

###############################################################################################

######## ------ startTrainingJob ------ ######## START

module "flowjoai_start_training_job" {
  source = "../../Lambda/flowjoai-start-training-job"
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

######## ------ startTrainingJob ------ ######## END

###############################################################################################

######## ------ updateModelRoute ------ ######## START

module "flowjoai_update_model" {
  source = "../../Lambda/flowjoai-update-model"
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
######## ------ updateModelRoute ------ ######## END

###############################################################################################