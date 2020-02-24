FROM golang as builder

# Download and install the latest release of dep
RUN go get -u github.com/golang/dep/cmd/dep

# Copy the code from the host and compile it
COPY Gopkg.toml Gopkg.lock $GOPATH/src/taxiGrpcService/src/

WORKDIR $GOPATH/src/taxiGrpcService/src
RUN dep ensure --vendor-only
ADD . ./

RUN go build -o /go/bin/taxiGrpcService cmd/server/main.go
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -installsuffix cgo -o /go/bin/taxiGrpcService cmd/server/main.go

# Compressing the image
FROM scratch
COPY --from=builder /go/bin/taxiGrpcService /go/bin/taxiGrpcService
