FROM alpine:3
ENV PATH="/app/bin:${PATH}"
RUN apk add bash \
	docker-cli \
	mongodb-tools \
	mysql-client \
	openssl \
	restic \
	rsync \
	supercronic \
	vim \
	jq 
COPY ./root-fs/app /app
