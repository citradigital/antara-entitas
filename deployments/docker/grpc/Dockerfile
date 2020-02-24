FROM alpine

ENV GRPC_URL ${GRPC_URL}
ENV NATS_URL ${NATS_URL}

COPY deployments/docker/build/grpc /
COPY deployments/docker/build/wait-for-it.sh /
COPY deployments/docker/grpc/start.sh /

RUN apk add --update bash

RUN chmod +x /start.sh /wait-for-it.sh
ENTRYPOINT [ "/start.sh" ]
