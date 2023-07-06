PWD = $(shell pwd)

.PHONY: dev
dev:
	docker build --tag 'hugo-server:dev' .
	docker run -p 9001:9001 -v ${PWD}:/src hugo-server:dev hugo server --bind 0.0.0.0 -p 9001
