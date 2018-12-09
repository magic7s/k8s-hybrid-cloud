#/usr/bin/env bash
# Commands from https://istio.io/docs/examples/multicluster/gke/

export KUBECONFIG_MAIN="../kubeconfig_gke-hybrid-cloud"
export KUBECONFIG_REMOTE="../kubeconfig_eks-hybrid-cloud"

kubectl --kubeconfig=$KUBECONFIG_MAIN apply -f bookinfo.yaml
kubectl --kubeconfig=$KUBECONFIG_MAIN apply -f bookinfo-gateway.yaml
kubectl --kubeconfig=$KUBECONFIG_REMOTE apply -f reviews-v3.yaml

export INGRESS_HOST=$(kubectl --kubeconfig=$KUBECONFIG_MAIN -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl --kubeconfig=$KUBECONFIG_MAIN -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT

echo "---------"
echo "Access http://$GATEWAY_URL/productpage repeatedly and each version of reviews should be equally loadbalanced, including reviews-v3 in the remote cluster (red stars). It may take several accesses (dozens) to demonstrate the equal loadbalancing between reviews versions."
