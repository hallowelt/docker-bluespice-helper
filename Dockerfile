ARG BASE_IMAGE=alpine:3.20.3
FROM $BASE_IMAGE
RUN apk add bash 
COPY --chmod=755 ./app/bin/prepare-bluespice /app/bin/prepare-bluespice
CMD ["/app/bin/prepare-bluespice"]
