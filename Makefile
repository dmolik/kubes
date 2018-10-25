
REPO ?= graytshirt

KUBE_VERSION=$(shell cat VERSION|grep KUBERNETES|sed -e 's/KUBERNETES[\ \t]*=[\ \t]*//' )
ETCD_VERSION=$(shell cat VERSION|grep ETCD|sed -e 's/ETCD[\ \t]*=[\ \t]*//')
KEEPALIVED_VERSION=$(shell cat VERSION|grep KEEPALIVED|sed -e 's/KEEPALIVED[\ \t]*=[\ \t]*//')
HAPROXY_VERSION=$(shell cat VERSION|grep HAPROXY|sed -e 's/HAPROXY[\ \t]*=[\ \t]*//')

.PHONY: version

all: build etcd-build haproxy-build keepalived-build push

version:
	@echo "Pushing to Repo    = $(REPO)"
	@echo
	@echo "Kubernetes Version = $(KUBE_VERSION)"
	@echo "Etcd Version       = $(ETCD_VERSION)"
	@echo "Keepalived Version = $(KEEPALIVED_VERSION)"
	@echo "Haproxy Version    = $(HAPROXY_VERSION)"
	$(shell sed -i -e '/##\ VERSIONS/,$$d' README.md)
	@echo "## VERSIONS" >> README.md
	@echo >> README.md
	@echo "  - Kubernetes: $(KUBE_VERSION)" >> README.md
	@echo "  - Etcd:       $(ETCD_VERSION)" >> README.md
	@echo "  - Keepalived: $(KEEPALIVED_VERSION)" >> README.md
	@echo "  - Haproxy:    $(HAPROXY_VERSION)" >> README.md

keepalived-build:
	@sed -e s/@VERSION@/$(KEEPALIVED_VERSION)/ Dockerfile.keepalived.in > Dockerfile.keepalived
	docker build . -f Dockerfile.keepalived -t $(REPO)/keepalived:latest

haproxy-build:
	@sed -e s/@VERSION@/$(HAPROXY_VERSION)/ Dockerfile.haproxy.in > Dockerfile.haproxy
	docker build . -f Dockerfile.haproxy -t $(REPO)/haproxy:latest

etcd-build:
	@sed -e s/@VERSION@/$(ETCD_VERSION)/ Dockerfile.etcd-builder.in > Dockerfile.etcd-builder
	docker build . -f Dockerfile.etcd-builder -t $(REPO)/etcd-builder:latest
	docker build . -f Dockerfile.etcd -t $(REPO)/etcd:latest

build:
	@sed -e s/@VERSION@/$(KUBE_VERSION)/ Dockerfile.in > Dockerfile
	docker build . -t $(REPO)/kubernetes-builder:latest
	docker build -f Dockerfile.kube-controller-manager -t $(REPO)/kube-controller-manager:latest .
	docker build -f Dockerfile.kube-apiserver -t $(REPO)/kube-apiserver:latest .
	docker build -f Dockerfile.kube-scheduler -t $(REPO)/kube-scheduler:latest .
	docker build -f Dockerfile.kube-proxy -t $(REPO)/kube-proxy:latest .

push:
	docker push $(REPO)/kube-apiserver
	docker push $(REPO)/kube-scheduler
	docker push $(REPO)/kube-proxy
	docker push $(REPO)/kube-controller-manager
	docker push $(REPO)/etcd
	docker push $(REPO)/haproxy
	docker push $(REPO)/keepalived
