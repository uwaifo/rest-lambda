package main

import (
	"log"

	"github.com/TheGuarantors/pms-rest-api-service/api/hello"
	"github.com/TheGuarantors/pms-rest-api-service/api/system"

	"github.com/TheGuarantors/pms-rest-api-service/internal/routing"
)

func main() {
	engine := routing.Build()
	routing.AddRoute(engine, hello.Path, hello.Method, hello.ProcessRequest)
	routing.AddRoute(engine, system.Path, system.Method, system.ProcessRequest)

	if err := engine.Run(); err != nil {
		log.Printf("Error starting gin %v", err)
	}

	log.Printf("Application exiting.")

}
