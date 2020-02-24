DIR=deployments/docker
RECIPE=${DIR}/docker-compose.yaml
NAMESPACE=builder${COMPONENT}
MIGRATION_PATH=`pwd`/migrations/test

include .env
export $(shell sed 's/=.*//' .env)

IMAGE_TAG ?= master
export $IMAGE_TAG

CACHE_DIR?=/tmp/cache

DIND_PREFIX ?= $(HOME)
ifneq ($(HOST_PATH),)
DIND_PREFIX := $(HOST_PATH)
endif
ifeq ($(CACHE_PREFIX),)
	CACHE_PREFIX=/tmp
endif

PREFIX=$(shell echo $(PWD) | sed -e s:$(HOME):$(DIND_PREFIX):)
UID=$(shell whoami)

C=$(shell docker-compose -f deployments/docker/docker-compose.yaml -p ${NAMESPACE} ps -q testnats)
NETWORK=$(shell docker inspect -f "{{.NetworkSettings.Networks }}" ${C} | cut -f 1 -d:|cut -f 2 -d[)

.PHONY : test

migrate:
	docker run --network builder_default -v `pwd`/migrations/deploy:/migrations migrate/migrate -source file://migrations -database 'postgres://${DB_USER}:${DB_PASS}@testdb:5432/testdb?sslmode=disable' drop
	docker run --network builder_default -v `pwd`/migrations/deploy:/migrations migrate/migrate -source file://migrations -database 'postgres://${DB_USER}:${DB_PASS}@testdb:5432/testdb?sslmode=disable' up

quicktest:
	docker run \
		--network ${NAMESPACE}_default \
		--env-file .env \
		-v $(CACHE_PREFIX)/cache/go:/go/pkg/mod \
		-v $(CACHE_PREFIX)/cache/apk:/etc/apk/cache \
		-v $(PREFIX)/deployments/docker/build:/build \
		-v $(PREFIX)/:/src \
		-v $(PREFIX)/migrations:/migrations \
		-v $(PREFIX)/scripts/test.sh:/test.sh \
		-e UID=$(UID) \
		golang:1.12-alpine /test.sh
		
test: infratest
	docker run \
		--network ${NAMESPACE}_default \
		--env-file .env \
		-v $(CACHE_PREFIX)/cache/go:/go/pkg/mod \
		-v $(CACHE_PREFIX)/cache/apk:/etc/apk/cache \
		-v $(PREFIX)/deployments/docker/build:/build \
		-v $(PREFIX)/:/src \
		-v $(PREFIX)/migrations:/migrations \
		-v $(PREFIX)/scripts/test.sh:/test.sh \
		-e UID=$(UID) \
		golang:1.12-alpine /test.sh 

deps:
	@./scripts/deps.sh
	
buildtest: deps
	docker-compose -f ${RECIPE} -p ${NAMESPACE} build testapi

cleantest:
	docker-compose -f ${RECIPE} -p ${NAMESPACE} stop 
	docker-compose -f ${RECIPE} -p ${NAMESPACE} rm -f testdb
	docker-compose -f ${RECIPE} -p ${NAMESPACE} rm -f testapi
	docker-compose -f ${RECIPE} -p ${NAMESPACE} rm -f testredis
	docker-compose -f ${RECIPE} -p ${NAMESPACE} rm -f testnats

infratest:
	docker network create -d bridge ${NAMESPACE}_default ; /bin/true 
	docker-compose -f ${RECIPE} -p ${NAMESPACE} up -d --force-recreate testdb
	docker-compose -f ${RECIPE} -p ${NAMESPACE} up -d --force-recreate testnats
	docker-compose -f ${RECIPE} -p ${NAMESPACE} up -d --force-recreate testredis

runtest: cleantest buildtest infratest
	docker-compose -f ${RECIPE} -p ${NAMESPACE} run testapi /start.sh
	docker-compose -f ${RECIPE} -p ${NAMESPACE} down 

cleanbuildapi:
	rm -f ${DIR}/build-results/api
	docker-compose -f ${RECIPE} -p ${NAMESPACE} stop 
	docker-compose -f ${RECIPE} -p ${NAMESPACE} rm -f buildapi

runapi:


buildapi:
	docker run -v $(CACHE_PREFIX)/cache/go:/go/pkg/mod \
		-v $(CACHE_PREFIX)/cache/apk:/etc/apk/cache \
		-v $(PREFIX)/deployments/docker/build:/build \
		-v $(PREFIX)/scripts/build.sh:/build.sh \
		-v $(PREFIX)/:/src \
		-v $(PREFIX)/cmd:/src/cmd \
		golang:1.12.5-alpine /build.sh ${COMPONENT}

runapi: buildapi
	docker run --network ${NAMESPACE}_default --env-file .env -v `pwd`/deployments/docker/build/api:/api alpine /api

buildgrpc:
	docker run -v $(CACHE_PREFIX)/cache/go:/go/pkg/mod \
		-v $(CACHE_PREFIX)/cache/apk:/etc/apk/cache \
		-v $(PREFIX)/deployments/docker/build:/build \
		-v $(PREFIX)/scripts/build.grpc.sh:/build.sh \
		-v $(PREFIX)/:/src \
		-v $(PREFIX)/cmd:/src/cmd \
		golang:1.12.5-alpine /build.sh

rungrpc: buildgrpc
	docker run --network ${NAMESPACE}_default --env-file .env -v `pwd`/deployments/docker/build/grpc:/grpc alpine /grpc


cleanapi:
	docker-compose -f ${RECIPE} -p ${NAMESPACE} stop 
	docker-compose -f ${RECIPE} -p ${NAMESPACE} rm -f api

cleangrpc:
	docker-compose -f ${RECIPE} -p ${NAMESPACE} stop 
	docker-compose -f ${RECIPE} -p ${NAMESPACE} rm -f grpc
	# 
api: cleanapi buildapi
	docker-compose -f ${RECIPE} -p ${NAMESPACE} build --no-cache api 

grpc: cleangrpc buildgrpc
	docker-compose -f ${RECIPE} -p ${NAMESPACE} build --no-cache grpc 

gen: 
	docker run -v $(PREFIX):/gen -v $(PREFIX)/api:/api citradigital/toldata:v0.1.4 \
		-I /api/ \
		/api/${COMPONENT}.proto \
		--toldata_out=grpc:/gen --gogofaster_out=plugins=grpc:/gen
