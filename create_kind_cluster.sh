#!/bin/bash

# Parameters ################################

regname='kind-registry'
regport='5000'
ingress='nginx'  # use nginx or ambassador

#############################################

running="$(docker inspect -f '{{.State.Running}}' "${regname}" 2>/dev/null)"

if [ "${running}" != 'true' ]; then
    docker run -d --restart=always -p "127.0.0.1:${regport}:5000" --name "${regname}" registry:2
fi

# Create kind cluster
sed -e "s/REGPORT/$regport/g" -e "s/REGNAME/$regname/g" cluster_config.yml | kind create cluster --config -
echo "Waiting for cluster to start ..."; sleep 30

# Connect registry to K8s network
docker network connect "kind" "${regname}" || true

# Install Weave CNI
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

# Install nginx ingress controller
if [ $ingress == 'nginx' ]; then

    # Nginx ingress controller
    # Latest version of the nginx controller doesn't work
    #kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml
    kubectl apply -f ingress_deploy.yaml
    kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=90s

elif [ $ingress == 'ambassador' ]; then

    # Ambassador ingress controller
    kubectl apply -f https://github.com/datawire/ambassador-operator/releases/latest/download/ambassador-operator-crds.yaml
    kubectl apply -n ambassador -f https://github.com/datawire/ambassador-operator/releases/latest/download/ambassador-operator-kind.yaml
    kubectl wait --timeout=180s -n ambassador --for=condition=deployed ambassadorinstallations/ambassador

fi

