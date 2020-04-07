#!/usr/bin/env bash

start_run	:= $(shell date --rfc-3339 "ns")

image_path	:= "./images"

images 		:= $(shell find $(image_path) -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)

.PHONY: all $(images) config push test clean clean-unused clean-all

all: $(images)

$(images): config
	@echo -e "\e[1m${start_run} : Starting build run ... \e[0m"
	@find ./images/$@/ -mindepth 1 -maxdepth 1 -type f \
	-exec echo -e "\e[93mLaunching {} ... \e[92m" \; -exec {} \;

config: clean
	@for i in ${images} ; do \
		mkdir -p ${image_path}/$$i ; \
	done
	@find ${image_path}/ -type f -exec chmod 755 {} +

push:
	@echo -e "\e[93mPushing images ... \e[0m"
	@./images/push

test:
	@echo $(images)
	@./images/test

clean:
	@echo -e "\e[93mCleaning up ... \e[0m"
	@buildah unshare podman images --format "{{.ID}}" \
		--filter label=maintainer="Jonas Mauer <jam@kabelmail.net" \
		| xargs -r podman rmi -f

clean-unused:
	@echo -e "\e[93mCleaning up unused images ... \e[0m"
	@podman image prune -af

clean-all:
	@echo -e "\e[93mCleaning up all images ... \e[0m"
	@podman rmi -af
