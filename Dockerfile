FROM golang:latest

RUN mkdir -p /build

RUN cd $GOPATH  && apt-get update && apt-get install rsync -y \
	&& mkdir -p src/k8s.io/kubernetes \
	&& cd src/k8s.io/kubernetes \
	&& curl -L https://github.com/kubernetes/kubernetes/archive/v1.12.1.tar.gz | tar xz --strip-components=1 -C .

RUN cd $GOPATH/src/k8s.io/kubernetes \
	&& sed -i -e "/vendor\/github.com\/jteeuwen\/go-bindata\/go-bindata/d" hack/lib/golang.sh \
	&& sed -i -e "/export PATH/d" hack/generate-bindata.sh

RUN cd $GOPATH/src/k8s.io/kubernetes \
	&& LDFLAGS="" make WHAT=cmd/kube-controller-manager GOFLAGS=-v
RUN cd $GOPATH/src/k8s.io/kubernetes \
	&& LDFLAGS="" make WHAT=cmd/kube-apiserver GOFLAGS=-v
RUN cd $GOPATH/src/k8s.io/kubernetes \
	&& LDFLAGS="" make WHAT=cmd/kube-scheduler GOFLAGS=-v

RUN cd $GOPATH/src/k8s.io/kubernetes \
	&& cp _output/bin/kube-controller-manager /build \
	&& cp _output/bin/kube-apiserver /build \
	&& cp _output/bin/kube-scheduler /build
