# Containerized Highly Available Kubernetes

Best practices for Kubernetes deployments.

To build the containers run:

    make REPO="$PRIVATE_REPO_URI"

See the docs for an [architectural overview](docs/)

And the associated [Static Pod Manifests](docs/kubeconfigs/manifest.yml)

## VERSIONS

  - Kubernetes: 1.12.2
  - Etcd:       3.3.10
  - Keepalived: 2.0.9
  - Haproxy:    1.8.14
  - Strongswan: 5.7.1
  - Frr:        6.0
