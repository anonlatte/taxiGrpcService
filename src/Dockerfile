FROM golang

# Download and install the latest release of dep
ADD https://github.com/golang/dep/releases/download/v0.5.3/dep-linux-amd64 /usr/bin/dep

RUN chmod +x /usr/bin/dep

# Copy the code from the host and compile it
WORKDIR $GOPATH/src/golang-service/src/


COPY Gopkg.toml Gopkg.lock ./
RUN dep ensure --vendor-only

ADD . ./

RUN mkdir documents