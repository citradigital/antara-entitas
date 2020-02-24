package jidat_entitas

import (
	"context"
	"log"
	"os"
	"testing"
	"time"

	"github.com/citradigital/toldata"
	"github.com/stretchr/testify/assert"
)

func createentitas() *entitas {
	entitas := entitas{
		Fixtures: CreateFixtures(),
	}

	return &entitas
}

var lastID string

func TestInit(t *testing.T) {
	log.SetFlags(log.Lshortfile)
}

func TestHealthcheck(t *testing.T) {

	client, err := toldata.NewBus(context.Background(), toldata.ServiceConfiguration{URL: os.Getenv("NATS_URL")})

	assert.Equal(t, nil, err)
	defer client.Close()
	svc := NewentitasToldataClient(client)

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	_, err = svc.ToldataHealthCheck(ctx, nil)
	assert.Equal(t, nil, err)
}
