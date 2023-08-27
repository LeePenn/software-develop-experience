#!/bin/sh
docker build --rm -t  test:build . -f Dockerfile.build
docker create --name extract test:build
docker cp extract:/go/src/go/valeo/internal/cmd/scan/main ./main
docker rm -f extract
docker build --no-cache --rm -t test:run . -f Dockerfile.run
rm -rf ./main