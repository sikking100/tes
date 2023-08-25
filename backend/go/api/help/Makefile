build-gateway:
	cd ../../gateway && \
	make build
build:
	rm -rf ./dependency && \
	mkdir -p ./dependency/pkg && \
	cp -r ../../pkg ./dependency && \
	docker build --quiet . -t help-service:latest && \
	rm -rf ./dependency
build-all: build-gateway build
run:
	export GOOGLE_APPLICATION_CREDENTIALS=../../GOOGLE_APPLICATION_CREDENTIALS.json && \
	docker-compose up -d
start: build-all run
stop:
	docker-compose down