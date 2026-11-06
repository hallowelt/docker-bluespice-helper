FROM alpine:3
ENV PATH="/app/bin:${PATH}"
RUN apk add bash \
	docker-cli \
	mongodb-tools \
	mariadb-client \
	openssl \
	restic \
	rsync \
	supercronic \
	vim \
	tini \
	jq 
COPY ./root-fs/app /app

# Build info: value of build arg BUILDINFO, falls back to the UTC build timestamp (YmdHis)
ARG BUILDINFO
RUN mkdir -p /image && echo "${BUILDINFO:-$(date -u +%Y%m%d%H%M%S)}" > /image/BUILDINFO

WORKDIR /app
ENTRYPOINT ["/sbin/tini", "-s"]
