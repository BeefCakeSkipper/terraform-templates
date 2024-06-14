output "endpoint_url" {
  value = "${aws_api_gateway_stage.om_stage.invoke_url}/${var.api_function1}"
}


# output "endpoint_url" {
#   value = "${aws_api_gateway_stage.om_stage.invoke_url}/${var.endpoint_path}?amount=100&fromCurrency=USD&toCurrency=CAD"
# }

# output "endpoint_url" {
#   value = "${aws_lambda_function_url.lambda_url.function_url}"
# }