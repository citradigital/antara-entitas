FROM alpine

ENV DB_USER ${DB_USER}
ENV DB_PASS ${DB_PASS}
ENV DB_HOST ${DB_HOST}
ENV DB_PORT ${DB_PORT}
ENV DB_NAME ${DB_NAME}

COPY deployments/docker/build/api /
COPY deployments/docker/build/wait-for-it.sh /
COPY deployments/docker/api/start.sh /

RUN apk add --update bash ca-certificates

RUN chmod +x /start.sh /wait-for-it.sh
ENTRYPOINT [ "/start.sh" ]
