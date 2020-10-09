FROM golang:alpine as builder

RUN apk update && apk add git && apk add ca-certificates 
# For email certificate
RUN apk add -U --no-cache ca-certificates

COPY . $GOPATH/src/github.com/kiketordera/pilar-web/
WORKDIR $GOPATH/src/github.com/kiketordera/pilar-web/

RUN go get -d -v $GOPATH/src/github.com/kiketordera/pilar-web/cmd
# For Cloud Server
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags="-w -s" -o /go/bin/cmd $GOPATH/src/github.com/kiketordera/pilar-web/cmd

FROM scratch
COPY --from=builder /go/bin/cmd /cmd
COPY --from=builder /go/src/github.com/kiketordera/pilar-web/ui/ /go/src/github.com/kiketordera/pilar-web/ui/
# For email certificate, the 2 lines
VOLUME /etc/ssl/certs/ca-certificates.crt:/etc/ssl/certs/ca-certificates.crt
COPY --from=alpine /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

EXPOSE 8080/tcp

ENV GOPATH /go
ENTRYPOINT ["/cmd"]
