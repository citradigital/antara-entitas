FROM golang:1.11.1-alpine
ENV HTTPS_PROXY ${http_proxy}
ENV HTTP_PROXY ${http_proxy}
ENV GO111MODULE on
ARG COMPONENT
ENV COMPONENT ${COMPONENT}
ENV WORKDIR /go/src/${COMPONENT}
RUN echo "Building: ${COMPONENT}" >&2
RUN apk update
RUN apk add curl git gcc musl-dev
RUN mkdir -p ${WORKDIR}/${COMPONENT}
RUN mkdir -p ${WORKDIR}/cmd
RUN mkdir -p ${WORKDIR}/authn
RUN mkdir -p ${WORKDIR}/jukir

WORKDIR ${WORKDIR}
COPY authn/ ${WORKDIR}/authn/
COPY jukir/ ${WORKDIR}/jukir/

COPY *.go ${WORKDIR}/${COMPONENT}/
#COPY cmd/${COMPONENT}/*.go ${WORKDIR}/cmd
RUN go mod init cdl/mylife
COPY deployments/docker/buildapi/build.sh /
RUN chmod +x /build.sh
WORKDIR /
RUN curl -o /wait-for-it.sh https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh
WORKDIR ${WORKDIR}/${COMPONENT}
ENTRYPOINT [ "/build.sh" ]
