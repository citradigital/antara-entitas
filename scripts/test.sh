#!/bin/sh

apk add --update curl git gcc musl-dev
su -l nobody
cd /src/
export MIGRATION_PATH=/migrations/test
ls -lR /migrations
env
go test -test.parallel 4 -cover -coverprofile=coverage.out 
