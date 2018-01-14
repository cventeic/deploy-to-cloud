# deploy-to-cloud
Automate task of deploying web-apps (rails, node) to kubernetes on cloud service

# Required Packages
  Docker via https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/#set-up-the-repository

  Kubernetes via
    sudo snap install kubectl --classic

  gcloud init

# Deployment Process

0. Prepare web app(s) in local directory.

1. Establish Compute Engine with Container Cluster Service (Kubernetes)
    (ex. Kubeadm exposing kubernetes via local machine cluster)
    (ex. Google container engine exposing kubernetes on Google Compute Engine)

2. Adjust configure.rb to reflect local apps and container engine

3. Deploy apps to container engine / cloud service
     Execute "bundle exec ruby deploy.rb"

# Web Server and App Server Structure

- Phusion Passenger
    - Used successfully to serve both Rails and Node.js apps.
      - Rails must expose Rack interface.
      - Node must expose server.js file to server content.

    - See: https://github.com/phusion/passenger

- Nginx
    - Managed by Phusion Passenger instance
    - Serves static content efficiently (images, frontend code, etc)


# Kubernetes Deployment Structure

The following kubernentes entities are used:

```
                                --- Horizontal Pod AutoScaler
                               |
                              \|/
                               .
  Ingress --> Service --> Deployment

```

Ingress:
  Settings for accessing pods from the Internet
  Connects static IP address (Managed by Google) to the Service Instances
  Provides load balancing.
  Works successfully on Google Container Engine.
  Close but not quite successfull locally on kubeadm.

Service:
  Settings for accessing pods within cluster.
  Pods are transient and fungible instances.
  Service(s) are persistent proxies for service(s) pods can provide.

Deployment:
  Settings for deploying pods to cluster.
  Currently pods only contain frontend components (passenger instances).
  In the future pods will also deploy backends like postgres database.

Horizontal Pod AutoScaler:
  Automatically scales the number of pods in a replication controller, deployment or replica set based on observed CPU utilization
  New pods are instanciated when CPU of existing pods exceeds 50%


# Containerizing Issues /  ToDo

- Review scaling in google compute engine and scaling within kubernetes
    (horizontal pod autoscaler), optimize,verify and document operation.

- Use a random number in the docker_context and kubernetes_config directories
    so that we detect failure to (re)build content

- Make sure successfully deploys contain expected / new contents
  by adding random id on newly constructed images

- Inconsistent use of hiding / exposing details within project, cloud, apps

- Partitioning into containerize and deploy

- Remote registry uri specified in config

- Cloud provider setup (meta to kubernetes) automated or at least described

- Deployment to cloud should likely be independent of containerizing apps

- Deployment to cloud should likely occur once not per app

- Only add key refrences to kubernetes deployment when actual key is specified in config

- Remove the app-secretes.yml file from kubernetes-config directory after apply

## Web Server and App Server Issues / ToDo

- Pass "production, deployment, test" configuration through config.rb file.

- Adjust number of processes started by Passenger to provide backend services via node or rails.
    (Note: this is not related to serving static content including images and front end code)
    (Some thought needs to be put into this.
      Kubernetes and Google container engine will also spin up pods and nodes in response to demand.)

- Deployment should build the contents of dist and dist-server directories as
    part of deployment

- Deployment should not include the source code and other un-needed artifacts
    outside the dist and dist-server directories


