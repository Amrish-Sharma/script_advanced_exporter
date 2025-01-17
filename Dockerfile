FROM golang:1.14.1-alpine AS build-env

RUN apk add --update git gcc libc-dev
RUN go get -u github.com/prometheus/promu

RUN mkdir script_advanced_exporter
COPY .promu.yml script_advanced_exporter.go go.mod go.sum /go/script_advanced_exporter/

WORKDIR /go/script_advanced_exporter
RUN promu build

FROM alpine:3.11
LABEL upstream="https://github.com/adhocteam/script_advanced_exporter"
LABEL maintainer="james.kassemi@adhocteam.us"
RUN apk add --no-cache bash
COPY --from=build-env /go/script_advanced_exporter/script_advanced_exporter /bin/script-exporter
COPY script-exporter.yml /etc/script-exporter/config.yml

EXPOSE      9172
ENTRYPOINT  [ "/bin/script-exporter" ]
CMD ["-config.file=/etc/script-exporter/config.yml"]
