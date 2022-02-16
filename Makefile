PROJECT=quest

build-docker-image-%:
	# Build the docker image with the makefile variables for debugging.
	# We can use this built image to change the entrypoint defined in CMD.
	docker build -t $(PROJECT):$* . --target $*

debug: build-docker-image-debug
	# Create an ephemeral container that will be deleted on exit.
	# Opens a shell that we can interact with.
	docker run -it --rm \
		-v $(shell pwd):/app \
		-p 3000:3000 \
		$(PROJECT):debug

run: build-docker-image-prod
	# Pretend we're in a production environment. Run the real thing.
	docker run -it --rm \
		-p 3000:3000 \
		$(PROJECT):prod