 

//////////////////////////////////////////////////////////////////////////////
# This is required to get the AWS region via ${data.aws_region.current}.
data "aws_region" "current" {
} 
 
# Set the generated URL as an output. Run `terraform output url` to get this.
output "url" {
  value = "${aws_api_gateway_deployment.api_v1.invoke_url}${aws_api_gateway_resource.pms-rest-api.path}"
}
