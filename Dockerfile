FROM golang
ADD . /go/src/golangService
RUN go install golangService/cmd/server/server
ENTRYPOINT ["/go/bin/golangService"]
EXPOSE 8080