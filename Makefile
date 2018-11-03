
REPO    ?= graytshirt
BUILDER ?= docker

KUBE_VERSION=$(shell cat VERSION|grep KUBERNETES|sed -e 's/KUBERNETES[\ \t]*=[\ \t]*//' )
ETCD_VERSION=$(shell cat VERSION|grep ETCD|sed -e 's/ETCD[\ \t]*=[\ \t]*//')
KEEPALIVED_VERSION=$(shell cat VERSION|grep KEEPALIVED|sed -e 's/KEEPALIVED[\ \t]*=[\ \t]*//')
STRONGSWAN_VERSION=$(shell cat VERSION|grep STRONGSWAN|sed -e 's/STRONGSWAN[\ \t]*=[\ \t]*//')
HAPROXY_VERSION=$(shell cat VERSION|grep HAPROXY|sed -e 's/HAPROXY[\ \t]*=[\ \t]*//')

.PHONY: version

all: kube etcd haproxy keepalived

version:
	@echo "Pushing to Repo    = $(REPO)"
	@echo
	@echo "Kubernetes Version = $(KUBE_VERSION)"
	@echo "Etcd Version       = $(ETCD_VERSION)"
	@echo "Keepalived Version = $(KEEPALIVED_VERSION)"
	@echo "Haproxy Version    = $(HAPROXY_VERSION)"
	@echo "Strongswan Version = $(STRONGSWAN_VERSION)"
	$(shell sed -i '' -e '/##\ VERSIONS/,$$d' README.md )
	@echo "## VERSIONS" >> README.md
	@echo >> README.md
	@echo "  - Kubernetes: $(KUBE_VERSION)" >> README.md
	@echo "  - Etcd:       $(ETCD_VERSION)" >> README.md
	@echo "  - Keepalived: $(KEEPALIVED_VERSION)" >> README.md
	@echo "  - Haproxy:    $(HAPROXY_VERSION)" >> README.md
	@echo "  - Strongswan: $(STRONGSWAN_VERSION)" >> README.md

kube: kube-build kube-push
etcd: etcd-build etcd-push
haproxy: haproxy-build haproxy-push
keepalived: keepalived-build keepalived-push
strongswan: strongswan-build strongswan-push

strongswan-build:
	@sed -e s/@VERSION@/$(STRONGSWAN_VERSION)/ Dockerfile.strongswan.in > Dockerfile.strongswan
	$(BUILDER) build -f Dockerfile.strongswan -t $(REPO)/strongswan:$(STRONGSWAN_VERSION) .

keepalived-build:
	@sed -e s/@VERSION@/$(KEEPALIVED_VERSION)/ Dockerfile.keepalived.in > Dockerfile.keepalived
	$(BUILDER) build -f Dockerfile.keepalived -t $(REPO)/keepalived:$(KEEPALIVED_VERSION) .

haproxy-build:
	@sed -e s/@VERSION@/$(HAPROXY_VERSION)/ Dockerfile.haproxy.in > Dockerfile.haproxy
	$(BUILDER) build -f Dockerfile.haproxy -t $(REPO)/haproxy:$(HAPROXY_VERSION) .

etcd-build:
	@sed -e s/@VERSION@/$(ETCD_VERSION)/ Dockerfile.etcd-builder.in > Dockerfile.etcd-builder
	$(BUILDER) build -f Dockerfile.etcd-builder -t $(REPO)/etcd-builder:latest .
	$(BUILDER) build -f Dockerfile.etcd -t $(REPO)/etcd:$(ETCD_VERSION) .

kube-build:
	@sed -e s/@VERSION@/$(KUBE_VERSION)/ Dockerfile.in > Dockerfile
	$(BUILDER) build -f Dockerfile -t $(REPO)/kubernetes-builder:latest .
	$(BUILDER) build -f Dockerfile.kube-controller-manager -t $(REPO)/kube-controller-manager:$(KUBE_VERSION) .
	$(BUILDER) build -f Dockerfile.kube-apiserver -t $(REPO)/kube-apiserver:$(KUBE_VERSION) .
	$(BUILDER) build -f Dockerfile.kube-scheduler -t $(REPO)/kube-scheduler:$(KUBE_VERSION) .
	$(BUILDER) build -f Dockerfile.kube-proxy -t $(REPO)/kube-proxy:$(KUBE_VERSION) .

haproxy-push:
	$(BUILDER) push $(REPO)/haproxy:$(HAPROXY_VERSION)
	$(BUILDER) tag  $(REPO)/haproxy:$(HAPROXY_VERSION) $(REPO)/haproxy:latest
	$(BUILDER) push $(REPO)/haproxy:latest

keepalived-push:
	$(BUILDER) push $(REPO)/keepalived:$(KEEPALIVED_VERSION)
	$(BUILDER) tag  $(REPO)/keepalived:$(KEEPALIVED_VERSION) $(REPO)/keepalived:latest
	$(BUILDER) push $(REPO)/keepalived:latest

strongswan-push:
	$(BUILDER) push $(REPO)/strongswan:$(STRONGSWAN_VERSION)
	$(BUILDER) tag  $(REPO)/strongswan:$(STRONGSWAN_VERSION) $(REPO)/strongswan:latest
	$(BUILDER) push $(REPO)/strongswan:latest

etcd-push:
	$(BUILDER) push $(REPO)/etcd:$(ETCD_VERSION)
	$(BUILDER) tag  $(REPO)/etcd:$(ETCD_VERSION) $(REPO)/etcd:latest
	$(BUILDER) push $(REPO)/etcd:latest

kube-push:
	$(BUILDER) push $(REPO)/kube-apiserver:$(KUBE_VERSION)
	$(BUILDER) tag  $(REPO)/kube-apiserver:$(KUBE_VERSION) $(REPO)/kube-apiserver:latest
	$(BUILDER) push $(REPO)/kube-apiserver:latest
	$(BUILDER) push $(REPO)/kube-scheduler:$(KUBE_VERSION)
	$(BUILDER) tag  $(REPO)/kube-scheduler:$(KUBE_VERSION) $(REPO)/kube-scheduler:latest
	$(BUILDER) push $(REPO)/kube-scheduler:latest
	$(BUILDER) push $(REPO)/kube-proxy:$(KUBE_VERSION)
	$(BUILDER) tag  $(REPO)/kube-proxy:$(KUBE_VERSION) $(REPO)/kube-proxy:latest
	$(BUILDER) push $(REPO)/kube-proxy:latest
	$(BUILDER) push $(REPO)/kube-controller-manager:$(KUBE_VERSION)
	$(BUILDER) tag  $(REPO)/kube-controller-manager:$(KUBE_VERSION) $(REPO)/kube-controller-manager:latest
	$(BUILDER) push $(REPO)/kube-controller-manager:latest
