#!/bin/sh

apk update
apk add curl git gcc musl-dev

cd /src
env
CGO_ENABLED=0 GOOS=linux go build -o /build/grpc ./cmd/grpc/main.go
