#!/bin/sh

/wait-for-it.sh $DB_HOST:$DB_PORT -- echo "Starting..."
/grpc
