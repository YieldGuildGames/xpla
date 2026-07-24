PROJECT			:= xpla-371616
VERSION	    	:= $(shell cat version.txt)
IMAGE_NAME 		?= gcr.io/${PROJECT}/xpla
IMAGE_VERSION 	?= $(shell git describe --tags --always --dirty --abbrev=6)-${VERSION}
IMAGE			?= ${IMAGE_NAME}:${IMAGE_VERSION}
BINARY_IMAGE	?= ${IMAGE}-binary

.PHONY: current image image-binary image-source push push-source

xpla:
	git clone https://github.com/xpladev/xpla

current: xpla
	cd xpla; git fetch; git reset --hard ${VERSION}

image: image-binary

image-binary:
	docker build --force-rm -f Dockerfile.binary -t "${BINARY_IMAGE}" .

image-source: current
	cd xpla; docker build --force-rm -f ../Dockerfile -t "${IMAGE}" .

push: image
	docker push ${BINARY_IMAGE}

push-source: image-source
	docker push ${IMAGE}
