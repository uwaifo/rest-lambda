package hello

import (
	"fmt"
	"net/http"

	"github.com/TheGuarantors/pms-rest-api-service/internal/routing"
	"github.com/gin-gonic/gin"
)

const Path = "/hello"
const Method = routing.GET

func ProcessRequest(c *gin.Context) {
	name := c.Query("name")
	c.JSON(http.StatusOK, gin.H{"msg": fmt.Sprintf("Hello %v!", name)})
}
