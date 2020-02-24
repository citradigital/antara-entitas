#!/bin/sh

cp /wait-for-it.sh /srv
go build -ldflags "-extldflags '-static'" -o /srv/api ../cmd/main.go
