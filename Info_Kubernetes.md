# Kubernetes Architecture

## Here are some important Kubernetes term you should know about

pod: group of one or more containers running on a node

node: a server inside of a Kubernetes cluster

cluster: a group of servers managed by Kubernetes

master: the server that runs Kubernetes and manages other servers

worker: servers managed by the master server

deployment: settings for deploying pods to cluster

service: settings for accessing pods within cluster

ingress: settings for accessing pods from the Internet

## A standard Kubernetes cluster has following components

etcd - Distributed key-value store for configuration and service discovery.
weave/flannel - Container Network Interface for connecting services
kube-apiserver - API server for management and orchestration
kube-controller-manager - Controls Kubernetes services
kube-discovery - Service discovery
kube-dns - DNS server for internal hostnames
kube-proxy - Routes traffic through proxy
kube-schedular - Schedules containers on the cluster.


# How To (Kubeadm Specific)

## Install

1. Install Docker per https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/#uninstall-old-versions

2. Install kubectl per https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-with-snap-on-ubuntu

3. Install kubeadm per https://kubernetes.io/docs/setup/independent/install-kubeadm/


## (Re)Initiailze

1. sudo kubeadm reset

2. sudo kubeadm init --kubernetes-version v1.7.2

3. exec instructions

     sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
     sudo chown $(id -u):$(id -g) $HOME/.kube/config

4. allow master for apps.

     kubectl taint nodes --all node-role.kubernetes.io/master-


5. Weavenet network plugin

    kubectl apply -n kube-system -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

    https://www.weave.works/docs/net/latest/kube-addon/

6. Dashboard Installshitrall
    kubectl create -f https://git.io/kube-dashboard

7. Weavescope

    kubectl apply --namespace kube-system -f "https://cloud.weave.works/k8s/scope.yaml?k8s-version=$(kubectl version | base64 | tr -d '\n')"

    kubectl port-forward -n kube-system "$(kubectl get -n kube-system pod --selector=weave-scope-component=app -o jsonpath='{.items..metadata.name}')" 4040

8. Dashboard

  It is likely that the Dashboard is already installed on your cluster. Check with the following command:
    $ kubectl get pods --all-namespaces | grep dashboard

  If it is missing, you can install the latest stable release by running the following command:
    $ kubectl create -f https://git.io/kube-dashboard

  The easiest way to access Dashboard is to use kubectl. Run the following command in your desktop environment:

    $ kubectl proxy

    kubectl will handle authentication with apiserver and make Dashboard available at http://localhost:8001/ui

## Status and Info Commands

  kubectl get node
  kubectl get pods --all-namespaces

Describe contexts:
  kubectl config get-contexts
  kubectl config current-context

Select context:
  kubectl config use-context

Get yaml from actual running instances:
  kubectl get po,deployment,rc,rs,ds,no,job -o yaml?

## Demo / Test

- Namespace: kubectl create namespace sock-shop

- Demo:
    kubectl apply -n sock-shop -f "https://github.com/microservices-demo/microservices-demo/blob/master/deploy/kubernetes/complete-demo.yaml?raw=true"

- 'kubectl proxy' - able to access ports from browser

- Get port number to access
    kubectl -n sock-shop get svc front-end

    If
      kubectl -n sock-shop get svc front-end
      NAME        CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
      front-end   10.106.93.4   <nodes>       80:30001/TCP   1m

    Open browser 127.0.0.1:30001

- To uninstall the socks shop, run:
   kubectl delete namespace sock-shop


- If you forgot the cluster token, you can generate a new one with command:
root@system-mining: kubeadm token generate

## Tear down

- To undo what kubeadm did, you should first drain the node and make sure that the node is empty before shutting it down.

Talking to the master with the appropriate credentials, run:
kubectl drain <node name> --delete-local-data --force --ignore-daemonsets
kubectl delete node <node name>

- Then, on the node being removed, reset all kubeadm installed state:
kubeadm reset

- If you wish to start over simply run kubeadm init or kubeadm join with the appropriate arguments.

# Working with namespaces

- setup namespace:
  kubectl create namespace sock-shop

- install/start:
  kubectl apply -n sock-shop -f "https://github.com/microservices-demo/microservices-demo/blob/master/deploy/kubernetes/complete-demo.yaml?raw=true"

- Find out the port that the NodePort feature of services allocated for the front-end service by running:
kubectl -n sock-shop get svc front-end

Sample output:
NAME        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
front-end   10.110.250.153   <nodes>       80:30001/TCP   59s

- monitor for up status: It takes several minutes to download and start all the containers, watch the output of kubectl get pods -n sock-shop to see when they’re all up and running.

- uninstall: kubectl delete namespace sock-shop


# Ingress

## Template yaml and how to set up https
  https://zihao.me/post/creating-a-kubernetes-cluster-from-scratch-with-kubeadm/

## Role Based Access Control
  https://github.com/kubernetes/ingress/tree/master/examples/rbac/nginx


# Troubleshooting

If your container is having trouble starting, you can use
  kubectl exec -it [pod name] bash


If ingress isn't able to use the ip address...
  Go to GCE console... Network Services... Load Balancing...
     and delete existing balancer.

  A new load balancer is created when an new ingress instance is created.


# Minicube
- Starting minicube will auto start any services and deployments that were
    prevously loaded (configuration persistence)

## Start minikube
minikube start

## Get status dashboard
minikube dashboard

## Make shell use right docker environment for minikube
eval (minikube docker-env)

## Access web page
minikube service test-app-load-balancer --url




