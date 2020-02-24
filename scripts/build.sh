#!/bin/sh

SRC=$1
apk update
apk add curl git gcc musl-dev

cd /src
env
CGO_ENABLED=0 GOOS=linux go build -o /build/api ./cmd/$SRC/main.go
