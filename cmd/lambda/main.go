package main

import (
	"github.com/TheGuarantors/pms-rest-api-service/api/hello"
	// "github.com/TheGuarantors/pms-rest-api-service/api/system"
	"github.com/TheGuarantors/pms-rest-api-service/internal/routing"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	ginadapter "github.com/awslabs/aws-lambda-go-api-proxy/gin"
)

func main() {
	engine := routing.Build()

	routing.AddRoute(engine, hello.Path, hello.Method, hello.ProcessRequest)
	//routing.AddRoute(engine, system.Path, system.Method, system.ProcessRequest)

	proxy := func(req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
		adapter := ginadapter.New(engine)
		return adapter.Proxy(req)
	}

	lambda.Start(proxy)
}
