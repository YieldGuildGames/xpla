PROJECT			:= yggproj
VERSION	    	:= $(shell cat version.txt)
IMAGE_NAME 		?= gcri.io/${PROJECT}/xpla
IMAGE_VERSION 	?= ${VERSION}-$(shell git describe --tags --always --dirty --abbrev=6)
IMAGE			?= ${IMAGE_NAME}:${IMAGE_VERSION}

xpla:
	git clone https://github.com/xpladev/xpla

current: xpla
	cd xpla; git reset --hard ${VERSION}

image: current
	cd xpla; docker build --force-rm -t ${IMAGE} .

push: image
	docker push ${IMAGE}
