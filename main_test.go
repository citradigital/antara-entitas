package jidat_entitas

import (
	"context"
	"log"
	"os"
	"testing"

	"github.com/citradigital/toldata"
)

var d *entitas

func consumeentitas() *entitas {
	PrepareDB()
	b := entitas{
		Db:       dbConnPool,
		Fixtures: CreateFixtures(),
	}
	return &b
}

var natsURL string

func TestMain(m *testing.M) {
	natsURL = os.Getenv("NATS_URL")
	log.SetFlags(log.Lshortfile | log.Lmicroseconds)
	d = consumeentitas()
	ctx, cancel := context.WithCancel(context.Background())

	log.Println("init")
	bus, err := toldata.NewBus(ctx, toldata.ServiceConfiguration{URL: natsURL})
	if err != nil {
		log.Fatal(err)
	}
	d.Bus = bus

	defer func() {
		log.Println("closing")
		bus.Close()
	}()
	srv := NewentitasToldataServer(bus, d)
	done, err := srv.Subscribeentitas()

	if err != nil {
		log.Fatal(err)
	}

	code := m.Run()

	log.Println("exiting")
	cancel()
	<-done
	os.Exit(code)
}
