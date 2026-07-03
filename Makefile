.PHONY: all generate check build simulator device mock test screenshots archive export upload release clean

all: check

generate:
	bun run ios:generate

check:
	bun run ios:check

build:
	bun run ios:build

simulator:
	bun run ios:simulator

device:
	bun run ios

mock:
	bun run ios:mock

test:
	bun run ios:test

screenshots:
	bun run ios:screenshots

archive:
	bun run ios:archive

export:
	bun run ios:export

upload:
	bun run ios:upload

release:
	bun run ios:release

clean:
	rm -rf build
