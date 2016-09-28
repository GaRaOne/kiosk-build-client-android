QT := 5.7.0
QTM := 5.7
TAG := picokiosk/kiosk-build-client-android

.PHONY: image

image: $(QTF)
	docker build --no-cache=true --build-arg QT=$(QT) --build-arg QTM=$(QTM) --tag $(TAG) .
