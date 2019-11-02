FROM golang:alpine AS build-env
WORKDIR /go/src
COPY . /go/src/welcomeapp
RUN cd /go/src/welcomeapp && go build .
#go build command creates a linux binary that can run without any go tooling.
USER root
RUN apt-get update -qq \
    && apt-get install -qqy apt-transport-https ca-certificates curl gnupg2 software-properties-common 
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"
RUN apt-get update  -qq \
    && apt-get install docker-ce=17.12.1~ce-0~debian -y
RUN usermod -aG docker jenkins

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
