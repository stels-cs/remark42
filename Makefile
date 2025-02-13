OS=linux
ARCH=amd64

bin:
	docker build -f Dockerfile.artifacts -t remark42.bin .
	- @docker rm -f remark42.bin 2>/dev/null || exit 0
	docker run -d --name=remark42.bin remark42.bin
	docker cp remark42.bin:/artifacts/remark42.$(OS)-$(ARCH) remark42
	docker rm -f remark42.bin

docker:
	docker build -t umputun/remark42 --build-arg SKIP_FRONTEND_TEST=true --build-arg SKIP_BACKEND_TEST=true .

dockerx:
	docker buildx build --build-arg SKIP_FRONTEND_TEST=true --build-arg SKIP_BACKEND_TEST=true \
		  --progress=plain --platform linux/amd64,linux/arm/v7,linux/arm64 \
		  -t ghcr.io/umputun/remark42:master -t umputun/remark42:master .

release:
	docker build -f Dockerfile.artifacts --no-cache --pull -t remark42.bin .
	- @docker rm -f remark42.bin 2>/dev/null || exit 0
	- @mkdir -p bin
	docker run -d --name=remark42.bin remark42.bin
	docker cp remark42.bin:/artifacts/remark42.linux-amd64.tar.gz bin/remark42.linux-amd64.tar.gz
	docker cp remark42.bin:/artifacts/remark42.linux-386.tar.gz bin/remark42.linux-386.tar.gz
	docker cp remark42.bin:/artifacts/remark42.linux-arm64.tar.gz bin/remark42.linux-arm64.tar.gz
	docker cp remark42.bin:/artifacts/remark42.darwin-amd64.tar.gz bin/remark42.darwin-amd64.tar.gz
	docker cp remark42.bin:/artifacts/remark42.freebsd-amd64.tar.gz bin/remark42.freebsd-amd64.tar.gz
	docker cp remark42.bin:/artifacts/remark42.windows-amd64.zip bin/remark42.windows-amd64.zip
	docker rm -f remark42.bin

race_test:
	cd backend/app && go test -race -mod=vendor -timeout=60s -count 1 ./...

backend:
	docker-compose -f compose-dev-backend.yml build

frontend:
	docker-compose -f compose-dev-frontend.yml build

rundev:
	docker pull umputun/baseimage:buildgo-latest
	SKIP_BACKEND_TEST=true SKIP_FRONTEND_TEST=true docker-compose -f compose-private.yml build
	docker-compose -f compose-private.yml up

.PHONY: bin backend
