
VERSION=$(shell cat VERSION)
all: build etcd-build push

etcd-build:
	docker build . -f Dockerfile.etcd-builder -t graytshirt/etcd-builder:latest
	docker build . -f Dockerfile.etcd -t graytshirt/etcd:latest

build:
	echo $(VERSION)
	sed -e s/@VERSION@/$(VERSION)/ Dockerfile.in > Dockerfile
	docker build . -t graytshirt/kubernetes-builder:latest
	docker build -f Dockerfile.kube-controller-manager -t graytshirt/kube-controller-manager:latest .
	docker build -f Dockerfile.kube-apiserver -t graytshirt/kube-apiserver:latest .
	docker build -f Dockerfile.kube-scheduler -t graytshirt/kube-scheduler:latest .
	docker build -f Dockerfile.kube-proxy -t graytshirt/kube-proxy:latest .

push:
	docker push graytshirt/kube-apiserver
	docker push graytshirt/kube-scheduler
	docker push graytshirt/kube-proxy
	docker push graytshirt/kube-controller-manager
	docker push graytshirt/etcd

