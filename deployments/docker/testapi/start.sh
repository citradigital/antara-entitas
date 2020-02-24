#!/bin/sh
set -e
set -x

jq -r ".dev|to_entries|map(\"export \(.key|ascii_upcase)=\(.value|tostring)\")|.[]" /config.json > /config.sh
source /config.sh
DBHOST=$_DBHOST
DBPORT=$_DBPORT
/wait-for-it.sh $DBHOST:$DBPORT -- echo "Starting..."
go test
