#!/usr/bin/env bash
protoc --proto_path=api/proto/v1 --proto_path=third_party --go_out=plugins=grpc:src/pkg/api/v1 taxiService.proto