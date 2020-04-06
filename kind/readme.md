# KIND

## install kind binary

see [kind documentation](https://kind.sigs.k8s.io/docs/user/quick-start/)

## start kind cluster

Create a Single-Node Kind K8s Cluster with the name "gitops" and some port mapping

    kind create cluster --config .\kind\kind-cluster.yaml

"kind create" will automatically add all information necessary to your kubeconfig file if your environment variable is set
You can export these information manually to a specific file via 

    kind export kubeconfig --kubeconfig ./kind-kubeconfig

Normally Kind has access to Docker Hub, etc. If your working behind a corporate proxy etc I had some problems.
I manually pulled all required images to my maschine and then loaded them into the Kind-Nodes via

    kind load docker-image quay.io/open-policy-agent/gatekeeper:v3.1.0-beta.8
    

## delete kind cluster

    kind delete cluster

## Debug information

I had problems connecting to my kind cluster after restarting my maschine. Kind is not designed for such "long lived test".
Delete your cluster and recreate it.

## further links

Information to Port Forwarding
https://github.com/kubernetes-sigs/kind/issues/758
https://banzaicloud.com/blog/kind-ingress/

