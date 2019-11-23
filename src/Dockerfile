FROM golang as builder
# Download and install the latest release of dep
RUN go get -u github.com/golang/dep/cmd/dep
# Copy the code from the host and compile it
COPY Gopkg.toml Gopkg.lock $GOPATH/src/taxiGrpcService/src/
WORKDIR $GOPATH/src/taxiGrpcService/src
RUN dep ensure --vendor-only
ADD . ./
#ENTRYPOINT ["go","run","cmd/server/main.go", "-grpc-port=48695", "-db-host=mysql:3306", "-db-user=root", "-db-password=root", "-db-schema=taxi"]
#TODO FOR PRODUCTION #
#RUN go build -o /go/bin/taxiGrpcService cmd/server/main.go
#RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -installsuffix cgo -o /go/bin/taxiGrpcService cmd/server/main.go
#FROM scratch
#COPY --from=builder /go/bin/taxiGrpcService /go/bin/taxiGrpcService
#ENTRYPOINT ["/go/bin/taxiGrpcService", "-grpc-port=48695", "-db-host=mysql:3306", "-db-user=root", "-db-password=root", "-db-schema=taxi"]
#EXPOSE 48695 48695