provider "aws" {
  version = "~> 2.0"
  region = "us-east-1"
}

/*
REST API
*/
resource aws_api_gateway_rest_api my_ip {
  name = "what-is-my-ip"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

/*
/ip Resource
*/
resource aws_api_gateway_resource my_ip {
  rest_api_id = aws_api_gateway_rest_api.my_ip.id
  parent_id = aws_api_gateway_rest_api.my_ip.root_resource_id
  path_part = "ip"
}

/*
GET /ip Method Request
*/
resource aws_api_gateway_method my_ip {
  rest_api_id = aws_api_gateway_resource.my_ip.rest_api_id
  resource_id = aws_api_gateway_resource.my_ip.id
  authorization = "NONE"
  http_method = "GET"
}

/*
MOCK Integration Request
Mock response with the HTTP Status Code set to 200
*/
resource aws_api_gateway_integration my_ip {
  rest_api_id = aws_api_gateway_method.my_ip.rest_api_id
  resource_id = aws_api_gateway_method.my_ip.resource_id
  http_method = aws_api_gateway_method.my_ip.http_method
  type = "MOCK"
  request_templates = {
    "application/json" = <<TEMPLATE
{
  "statusCode": 200
}
TEMPLATE
  }
}

/*
Method Response
Pass through anything with an HTTP Status Code of 200
*/
resource aws_api_gateway_method_response my_ip {
  rest_api_id = aws_api_gateway_method.my_ip.rest_api_id
  resource_id = aws_api_gateway_method.my_ip.resource_id
  http_method = aws_api_gateway_method.my_ip.http_method
  status_code = 200
}

/*
Integration Response
Generate the desired JSON output using $context variables.
*/
resource aws_api_gateway_integration_response my_ip {
  rest_api_id = aws_api_gateway_integration.my_ip.rest_api_id
  resource_id = aws_api_gateway_integration.my_ip.resource_id
  http_method = aws_api_gateway_integration.my_ip.http_method
  status_code = 200
  response_templates = {
    "application/json" = <<TEMPLATE
{
    "ip" : "$context.identity.sourceIp",
    "userAgent" : "$context.identity.userAgent",
    "time" : "$context.requestTime",
    "epochTime" : "$context.requestTimeEpoch"
}
TEMPLATE
  }
}

/*
REST API Deployment
Timestamp added to description to force deployment with each apply
*/
resource aws_api_gateway_deployment my_ip {
  depends_on = [
    aws_api_gateway_integration.my_ip]
  rest_api_id = aws_api_gateway_rest_api.my_ip.id

  stage_name = "demo"
}

/*
Output the service URL
*/
output my_ip_url {
  value = "${aws_api_gateway_deployment.my_ip.invoke_url}/${aws_api_gateway_resource.my_ip.path_part}"
}
