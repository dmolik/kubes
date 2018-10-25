
.PHONY: version

KUBE_VERSION=$(shell cat VERSION|grep KUBERNETES|sed -e 's/KUBERNETES[\ \t]*=[\ \t]*//' )
ETCD_VERSION=$(shell cat VERSION|grep ETCD|sed -e 's/ETCD[\ \t]*=[\ \t]*//')
KEEPALIVED_VERSION=$(shell cat VERSION|grep KEEPALIVED|sed -e 's/KEEPALIVED[\ \t]*=[\ \t]*//')
HAPROXY_VERSION=$(shell cat VERSION|grep HAPROXY|sed -e 's/HAPROXY[\ \t]*=[\ \t]*//')
all: build etcd-build haproxy-build keepalived-build push

version:
	@echo "Kubernetes Version = $(KUBE_VERSION)"
	@echo "Etcd Version       = $(ETCD_VERSION)"
	@echo "Keepalived Version = $(KEEPALIVED_VERSION)"
	@echo "Haproxy Version    = $(HAPROXY_VERSION)"

keepalived-build:
	@sed -e s/@VERSION@/$(KEEPALIVED_VERSION)/ Dockerfile.keepalived.in > Dockerfile.keepalived
	docker build . -f Dockerfile.keepalived -t graytshirt/keepalived:latest

haproxy-build:
	@sed -e s/@VERSION@/$(HAPROXY_VERSION)/ Dockerfile.haproxy.in > Dockerfile.haproxy
	docker build . -f Dockerfile.haproxy -t graytshirt/haproxy:latest

etcd-build:
	@sed -e s/@VERSION@/$(ETCD_VERSION)/ Dockerfile.etcd-builder.in > Dockerfile.etcd-builder
	docker build . -f Dockerfile.etcd-builder -t graytshirt/etcd-builder:latest
	docker build . -f Dockerfile.etcd -t graytshirt/etcd:latest

build:
	@sed -e s/@VERSION@/$(KUBE_VERSION)/ Dockerfile.in > Dockerfile
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
	docker push graytshirt/haproxy
	docker push graytshirt/keepalived
