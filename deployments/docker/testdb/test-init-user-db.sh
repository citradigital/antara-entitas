#!/bin/bash
# only used by "testdb" service
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  DROP DATABASE IF EXISTS testdb;
    CREATE USER db WITH ENCRYPTED PASSWORD 'db';
    CREATE DATABASE testdb;
    GRANT ALL PRIVILEGES ON DATABASE testdb TO db;
  \c testdb
        GRANT ALL PRIVILEGES ON DATABASE testdb TO db;
  CREATE EXTENSION pgcrypto;
  ALTER ROLE db superuser;
EOSQL
