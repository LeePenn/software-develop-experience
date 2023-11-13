#!/bin/sh
docker build --rm -t  test:build . -f Dockerfile.build
docker create --name extract test:build
docker cp extract:/go/src/main_scan ./
docker cp extract:/go/src/main_copy ./
docker cp extract:/go/src/main_frame ./
docker cp extract:/go/src/main_pre ./
#docker cp extract:/go/src/go/valeo/internal/cmd/copy/main ./main
docker rm -f extract
docker build --platform linux/amd64 --no-cache --rm -t test:run . -f Dockerfile.run
#docker build --no-cache --rm -t test:run . -f Dockerfile.run
rm -rf ./main