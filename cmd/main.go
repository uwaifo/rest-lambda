package main

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"strconv"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	echoadapter "github.com/awslabs/aws-lambda-go-api-proxy/echo"
	"github.com/joho/godotenv"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
)

type landlord struct {
	Id         int        `json:"id"`
	Name       string     `json:"name"`
	Properties []property `json:"properties"`
}
type property struct {
	Id      int    `json:"id"`
	Address string `json:"address"`
}

var sampleLandlords = []landlord{
	{
		Id:   1,
		Name: "peter",
		Properties: []property{
			{
				Id:      1,
				Address: "peter house 1",
			},
			{
				Id:      2,
				Address: "peter house two",
			},
		},
	},
	{
		Id:   2,
		Name: "paul",
		Properties: []property{
			{
				Id:      1,
				Address: "paul's crib",
			},
			{
				Id:      2,
				Address: "paul's mansion",
			},
			{
				Id:      3,
				Address: "paul's club house",
			},
		},
	},
}

//----------
// Handlers
//----------
func init() {
	err := godotenv.Load(".env")

	if err != nil {
		fmt.Println("Error loading .env file")
	}

}
func main() {
	e := echo.New()

	// Middleware
	e.Use(middleware.Logger())
	e.Use(middleware.Recover())

	apiRoute := e.Group("/api")
	{
		// PROPERTY ROUTES
		apiRoute.GET("/landlords", GetAllLandlords)
		apiRoute.GET("/landlords/:id", GetLandlord)
		apiRoute.GET("/landlords/:id/properties", GetAllPropertiesOfLandlord)

	}

	env := os.Getenv("APP_ENV")
	if env == "production" {
		lambda.Start(getHandler(e))
	} else {
		fmt.Printf("Enviroment : %s", env)
		//server.Logger.Fatal(server.Start(":3201"))
		// Start server
		e.Logger.Fatal(e.Start(":9090"))
	}

	// Start server
	//e.Logger.Fatal(e.Start(":9090"))
}

func getHandler(server *echo.Echo) func(ctx context.Context, req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	echoLambda := echoadapter.New(server)
	return func(ctx context.Context, req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
		// If no name is provided in the HTTP request body, throw an error
		return echoLambda.Proxy(req)
	}
}

func GetAllLandlords(c echo.Context) error {
	return c.JSON(http.StatusOK, "getting all landlords")

}

func GetLandlord(c echo.Context) error {
	id, _ := strconv.Atoi(c.Param("id"))
	var landlord landlord
	for _, v := range sampleLandlords {

		if v.Id == id {
			landlord = v
		}

	}
	return c.JSON(http.StatusOK, landlord)
}
func GetAllPropertiesOfLandlord(c echo.Context) error {
	id, _ := strconv.Atoi(c.Param("id"))
	var landlord landlord
	for _, v := range sampleLandlords {

		if v.Id == id {
			landlord = v
		}
	}

	return c.JSON(http.StatusOK, landlord.Properties)
}

/*

	r.Register("GET", "/api/landlords", landlords.GetAllLandlords)
	r.Register("GET", "/api/landlords/{id}", landlords.GetLandlord)

	r.Register("GET", "/api/landlords/{id}/properties", properties.GetAllPropertiesOfLandlord)
	r.Register("GET", "/api/landlords/{id}/properties/{id}", properties.GetPropertyOfLandlord)

	r.Register("GET", "/api/landlords/{id}/properties/{id}/applicants", applicants.GetAllApplicantsOfProperty)
	r.Register("GET", "/api/landlords/{id}/properties/{id}/applicants/latest", applicants.GetLatestApplicantOfProperty)
	r.Register("GET", "/api/landlords/{id}/properties/{id}/applicants/{id}", applicants.GetApplicantOfProperty)

	r.Register("GET", "/api/landlords/{id}/properties/{id}/applicants/approved", applicants.GetAllApprovedApplicantsOfProperty)
	r.Register("GET", "/api/landlords/{id}/properties/{id}/applicants/approved/latest", applicants.GetLatestApprovedApplicantOfProperty)

	r.Register("GET", "/api/landlords/{id}/properties/{id}/applicants/{id}/events", applicantevents.GetAllEventsOfApplicant)

	r.Register("GET", "/api/latest/applicants?limit={N}&offset={N}", applicants.GetLatestApplicants)
	r.Register("GET", "/api/latest/applicants/search/{S}", applicants.SearchApplicants)
*/
