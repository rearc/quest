#!/usr/bin/make

args = $(foreach a,$($(subst -,_,$1)_args),$(if $(value $a),$($a)))

build_args =
run_args =
stop_args =
logs_args =
follow_args =
command_args =

TASKS = \
				build \
				run \
				stop \
				logs \
				follow \
				exec

.PHONY: $(TASKS)

help:
	@echo
	@echo "make ACTION"
	@echo
	@echo "ACTION				COMMENT"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo

build: # Builds the app in docker
	docker build . -t rearc/quest --label rearc-quest

run: # Runs the built app in docker
	docker run -p 3000:3000 -d --name rearc-quest rearc/quest

stop: # Stops the built container in docker
	docker stop rearc-quest

logs: # Display logs for the container in docker
	docker logs rearc-quest

follow: # Follow logs in the container in docker
	docker logs --follow rearc-quest

exec: # Exec into the docker container
	docker exec -it rearc-quest /bin/bash