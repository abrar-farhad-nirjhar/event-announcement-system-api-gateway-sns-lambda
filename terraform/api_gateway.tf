resource "aws_api_gateway_rest_api" "events_api" {
  name        = "EventAnnouncementAPI"
  description = "API Gateway for Event Announcement System"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_request_validator" "events_api_validator" {
  rest_api_id                 = aws_api_gateway_rest_api.events_api.id
  name                        = "RequestValidator"
  validate_request_body       = true
  validate_request_parameters = false

}

resource "aws_api_gateway_model" "subscribe_model" {
  rest_api_id  = aws_api_gateway_rest_api.events_api.id
  name         = "SubscribeModel"
  content_type = "application/json"
  schema = jsonencode({
    type = "object"
    properties = {
      email = {
        type   = "string"
        format = "email"
      }
    }
    required = ["email"]
  })
}

resource "aws_api_gateway_model" "notify_model" {
  rest_api_id  = aws_api_gateway_rest_api.events_api.id
  name         = "NotifyModel"
  content_type = "application/json"
  schema = jsonencode({
    type = "object"
    properties = {
      name = {
        type = "string"
      },
      description = {
        type = "string"
      },
      date = {
        type   = "string"
        format = "date"
      }
    }
    required = ["name", "description", "date"]
  })
}

resource "aws_api_gateway_method" "subscribe_method" {
  rest_api_id          = aws_api_gateway_rest_api.events_api.id
  resource_id          = aws_api_gateway_resource.subscribe_resource.id
  http_method          = "POST"
  authorization        = "NONE"
  request_validator_id = aws_api_gateway_request_validator.events_api_validator.id
  request_models = {
    "application/json" = aws_api_gateway_model.subscribe_model.name
  }
}

resource "aws_api_gateway_method" "notify_method" {
  rest_api_id          = aws_api_gateway_rest_api.events_api.id
  resource_id          = aws_api_gateway_resource.notify_resource.id
  http_method          = "POST"
  authorization        = "NONE"
  request_validator_id = aws_api_gateway_request_validator.events_api_validator.id
  request_models = {
    "application/json" = aws_api_gateway_model.notify_model.name
  }

}

resource "aws_api_gateway_resource" "subscribe_resource" {
  rest_api_id = aws_api_gateway_rest_api.events_api.id
  parent_id   = aws_api_gateway_rest_api.events_api.root_resource_id
  path_part   = "subscribe"
}

resource "aws_api_gateway_resource" "notify_resource" {
  rest_api_id = aws_api_gateway_rest_api.events_api.id
  parent_id   = aws_api_gateway_rest_api.events_api.root_resource_id
  path_part   = "notify"
}

resource "aws_api_gateway_integration" "subscribe_integration" {
  rest_api_id             = aws_api_gateway_rest_api.events_api.id
  resource_id             = aws_api_gateway_resource.subscribe_resource.id
  http_method             = aws_api_gateway_method.subscribe_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.subscribe.invoke_arn
}

resource "aws_api_gateway_integration" "notify_integration" {
  rest_api_id             = aws_api_gateway_rest_api.events_api.id
  resource_id             = aws_api_gateway_resource.notify_resource.id
  http_method             = aws_api_gateway_method.notify_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.notify.invoke_arn

}

resource "aws_lambda_permission" "subscribe_api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.subscribe.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.events_api.execution_arn}/*/${aws_api_gateway_method.subscribe_method.http_method}${aws_api_gateway_resource.subscribe_resource.path}"
}

resource "aws_lambda_permission" "notify_api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notify.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.events_api.execution_arn}/*/${aws_api_gateway_method.notify_method.http_method}${aws_api_gateway_resource.notify_resource.path}"

}

resource "aws_api_gateway_deployment" "events_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.events_api.id
  depends_on  = [aws_api_gateway_integration.subscribe_integration, aws_api_gateway_integration.notify_integration]

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_integration.subscribe_integration.id,
      aws_api_gateway_integration.notify_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "dev" {
  stage_name    = "dev"
  rest_api_id   = aws_api_gateway_rest_api.events_api.id
  deployment_id = aws_api_gateway_deployment.events_api_deployment.id

  lifecycle {
    create_before_destroy = true
  }
}
