package jidat_entitas

import (
	"context"
	"encoding/json"
	fmt "fmt"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"os"

	"github.com/citradigital/toldata"
)

type entitas struct {
	Fixtures Fixtures
	Bus      *toldata.Bus
}

// ToldataHealthCheck returns empty string
func (c *entitas) ToldataHealthCheck(ctx context.Context, req *toldata.Empty) (*toldata.ToldataHealthCheckInfo, error) {

	ret := &toldata.ToldataHealthCheckInfo{Data: ""}
	return ret, nil
}
