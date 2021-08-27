# kind-cluster

This repository contains a shell script and supplementary manifest files needed to configure a Kind Kubernetes cluster that more closely resembles something you would see in production.

The following components have been added:

- 1 x Master node
- 2 x Worker nodes
- Local container registry
- Weave CNI
- Nginx Ingress / Ambassador Ingress controllers


This script is specifically written to work on Linux but may require some minor tweaking to get working on OSX or Windows.

### Setup

1. Clone this git repository
2. Execute the `create_kind_cluster.sh` script
```
$ ./create_kind_cluster.sh

```

