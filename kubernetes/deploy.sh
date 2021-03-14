#!/bin/bash

#
# A script to perform base Kubernetes deployment for the OAuth architecture
# This includes configuring ingress and setting up SSL both inside and outside the cluster
#

#
# Use the Minikube Docker Daemon rather than that of Docker Desktop for Mac
#
minikube profile api
eval $(minikube docker-env)

#
# Ensure that components can be exposed from the cluster over port 443 and use custom DNS
#
minikube addons enable ingress

#
# Deploy a secret for the external wildcard certificate for *.mycluster.com, to expose URLs to the host PC
#
kubectl delete secret mycluster-com-tls 2>/dev/null
kubectl create secret tls mycluster-com-tls --cert=./external/mycluster.com.ssl.pem --key=./external/mycluster.com.ssl.key
if [ $? -ne 0 ]
then
  echo "*** Problem creating ingress SSL wildcard secret ***"
  exit 1
fi

#
# Deploy a secret for the root CA for certificates used inside the cluster
#
kubectl delete secret svc-default-cluster-local 2>/dev/null
kubectl create secret tls svc-default-cluster-local --cert=./internal/svc.default.cluster.local.ca.pem --key=./internal/svc.default.cluster.local.ca.key
if [ $? -ne 0 ]
then
  echo "*** Problem creating secret for internal SSL Root Authority ***"
  exit 1
fi

#
# Next deploy certificate manager, which will issue certificates used inside the cluster
# The cluster issuer is then referenced by services when they are deployed
#
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.2.0/cert-manager.yaml
kubectl apply -f ./internal/clusterIssuer.yaml
if [ $? -ne 0 ]
then
  echo "*** Problem creating the Cert Manager Cluster Issuer ***"
  exit 1
fi
