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

# Build info: value of build arg BUILDINFO, `-` if not set
ARG BUILDINFO
RUN mkdir -p /image && echo "${BUILDINFO:--}" > /image/BUILDINFO

WORKDIR /app
ENTRYPOINT ["/sbin/tini", "-s"]
