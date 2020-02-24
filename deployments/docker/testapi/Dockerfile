FROM golang:1.12-alpine
ENV _DBHOST testdb
ENV _DBPORT 5432
ENV NATS_URL nats://testnats:4222
ENV CONFIG_FILE /config.json
ENV MIGRATION_PATH /migrations
ENV HTTPS_PROXY ${http_proxy}
ENV HTTP_PROXY ${http_proxy}
ENV GO111MODULE on
ENV COMPONENT ${COMPONENT}
ENV WORKDIR /go/src/${COMPONENT}
RUN apk update
RUN apk add curl git gcc musl-dev bash jq
RUN mkdir -p /migrations 
COPY migrations/test/* /migrations/ 
RUN mkdir -p ${WORKDIR}/${COMPONENT}
#RUN mkdir -p ${WORKDIR}/authn
WORKDIR ${WORKDIR}
#COPY authn/ ${WORKDIR}/authn/
COPY *.go ${WORKDIR}/${COMPONENT}/
RUN go mod init cdl/mylife
COPY configs/config.json /config.json
COPY deployments/docker/testapi/start.sh /
RUN curl -o /wait-for-it.sh https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh
RUN chmod +x /start.sh /wait-for-it.sh
WORKDIR ${WORKDIR}/${COMPONENT}
