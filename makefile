PROJECT			:= yggproj
VERSION	    	:= $(shell cat version.txt)
IMAGE_NAME 		?= gcr.io/${PROJECT}/xpla
IMAGE_VERSION 	?= $(shell git describe --tags --always --dirty --abbrev=6)-${VERSION}
IMAGE			?= ${IMAGE_NAME}:${IMAGE_VERSION}

xpla:
	git clone https://github.com/xpladev/xpla

current: xpla
	cd xpla; git fetch; git reset --hard ${VERSION}

image: current
	cd xpla; docker build --force-rm -f ../Dockerfile -t "${IMAGE}" .

push: image
	docker push ${IMAGE}
