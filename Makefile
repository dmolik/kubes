
.PHONY: build etcd-build

etcd-build:
	docker build . -f Dockerfile.etcd-builder -t graytshirt/etcd-builder:latest
	docker build . -f Dockerfile.etcd -t graytshirt/etcd:latest

build:
	docker build . -t graytshirt/kubernetes-builder:latest
	docker build -f Dockerfile.kube-controller-manager -t graytshirt/kube-controller-manager:latest .
	docker build -f Dockerfile.kube-apiserver -t graytshirt/kube-apiserver:latest .
	docker build -f Dockerfile.kube-scheduler -t graytshirt/kube-scheduler:latest .

push: $(build) $(etcd-build)
	docker push graytshirt/kube-apiserver
	docker push graytshirt/kube-scheduler
	docker push graytshirt/kube-controller-manager
	docker push graytshirt/etcd

all: push
