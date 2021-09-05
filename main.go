package main

import (
	"context"
	"fmt"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

// The entry point that runs your Lambda function code.
func main() {
	lambda.Start(handler)
}

// handler is your Lambda handler signature and includes the code which will be executed.
//
// See https://docs.aws.amazon.com/lambda/latest/dg/golang-handler.html for valid handler signatures.
// See https://github.com/aws/aws-lambda-go for event details.
func handler(ctx context.Context, evt events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	fmt.Printf("Processing request data for request %s.\n", evt.RequestContext.RequestID)

	fmt.Printf("Body size = %d.\n", len(evt.Body))

	fmt.Println("Headers:")
	for k, v := range evt.Headers {
		fmt.Printf("    %s: %s\n", k, v)
	}

	return events.APIGatewayProxyResponse{Body: evt.Body, StatusCode: 200}, nil
}
