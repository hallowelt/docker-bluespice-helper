ARG BASE_IMAGE=alpine:3
FROM $BASE_IMAGE
ENV PATH="/app/bin:${PATH}"
RUN apk add bash \
	docker-cli \
	mongodb-tools \
	mysql-client \
	openssl \
	restic \
	rsync \
	supercronic \
	vim
COPY ./root-fs/app /app
