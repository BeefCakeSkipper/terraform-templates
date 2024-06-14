terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region  = "ap-southeast-1"
}

resource "aws_lambda_function" "onemap_getTheme" {
  function_name = var.lambda_function_name
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_role.arn
  handler       = "main.lambda_handler"
  filename      = "deployment_package.zip"
  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.example,
  ]
}


resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}


resource "aws_iam_role" "lambda_role" {
  name               = "lambda_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

# resource "aws_lambda_function_url" "lambda_url" {
#   function_name      = aws_lambda_function.onemap_getTheme.function_name
#   authorization_type = "NONE"
# }

resource "aws_api_gateway_rest_api" "onemap_api" {
  name = "onemap-api"
  endpoint_configuration {
  types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "om_resource" {
  parent_id   = aws_api_gateway_rest_api.onemap_api.root_resource_id
  path_part   = var.api_function1
  rest_api_id = aws_api_gateway_rest_api.onemap_api.id
}

resource "aws_api_gateway_method" "om_method" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.om_resource.id
  rest_api_id   = aws_api_gateway_rest_api.onemap_api.id
}

resource "aws_api_gateway_integration" "om_integration" {
  http_method = aws_api_gateway_method.om_method.http_method
  resource_id = aws_api_gateway_resource.om_resource.id
  rest_api_id = aws_api_gateway_rest_api.onemap_api.id
  integration_http_method  = "POST"
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.onemap_getTheme.invoke_arn
}

resource "aws_api_gateway_deployment" "om_deployment" {
  rest_api_id = aws_api_gateway_rest_api.onemap_api.id

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.om_resource.id,
      aws_api_gateway_method.om_method.id,
      aws_api_gateway_integration.om_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "om_stage" {
  deployment_id = aws_api_gateway_deployment.om_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.onemap_api.id
  stage_name    = "om"
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.onemap_getTheme.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.myregion}:${var.accountId}:${aws_api_gateway_rest_api.onemap_api.id}/*/${aws_api_gateway_method.om_method.http_method}${aws_api_gateway_resource.om_resource.path}"
}