FROM golang:alpine AS build-env
WORKDIR /go/src
COPY . /go/src/welcomeapp
RUN cd /go/src/welcomeapp && go build .
#go build command creates a linux binary that can run without any go tooling.
RUN curl -fsSLO https://get.docker.com/builds/Linux/x86_64/docker-17.04.0-ce.tgz \
  && tar xzvf docker-17.04.0-ce.tgz \
  && mv docker/docker /usr/local/bin \
  && rm -r docker docker-17.04.0-ce.tgz

FROM alpine
#Alpine is one of the lightest linux containers out there, only a few MB
RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk*
WORKDIR /app
COPY --from=build-env /go/src/welcomeapp/welcomeapp /app
COPY --from=build-env /go/src/welcomeapp/templates /app/templates
COPY --from=build-env /go/src/welcomeapp/static /app/static
#Here we copy the binary from the first image (build-env) to the new alpine container as well as the html and css
EXPOSE 8080
ENTRYPOINT [ "./welcomeapp" ]
