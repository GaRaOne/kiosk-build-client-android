QT := 5.8.0
QTM := 5.8
TAG := picokiosk/kiosk-build-client-android

.PHONY: image

image: $(QTF)
	docker build --build-arg QT=$(QT) --build-arg QTM=$(QTM) --tag $(TAG) .
