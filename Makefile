SHELL := /bin/bash

.PHONY: setup install install-copy dry-run sync tools

setup:
	./scripts/setup-macos.sh

install:
	./scripts/install.sh

install-copy:
	./scripts/install.sh --mode copy

dry-run:
	./scripts/install.sh --dry-run

sync:
	./scripts/sync.sh

tools:
	./scripts/install-tools-macos.sh
