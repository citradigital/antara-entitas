package main

import (
	"context"
	"log"
	"os"
	"os/signal"
	"syscall"

	entitas "jidat_entitas"

	"github.com/citradigital/toldata"
)

func main() {
	ctx, cancel := context.WithCancel(context.Background())

	natsURL := os.Getenv("NATS_URL")

	d := &entitas.entitas{}

	bus, err := toldata.NewBus(ctx, toldata.ServiceConfiguration{URL: natsURL})
	if err != nil {
		log.Fatalln(err)
	}
	defer bus.Close()
	svr := entitas.NewentitasToldataServer(bus, d)

	wait, err := svr.Subscribeentitas()

	sigs := make(chan os.Signal, 1)
	done := make(chan bool, 1)
	signal.Notify(sigs, syscall.SIGINT, syscall.SIGTERM)

	go func() {
		_ = <-sigs
		done <- true
	}()
	log.Println("entitas started")
	<-done
	cancel()
	log.Println("entitas stopped")
	<-wait
}
