# deploy-to-cloud
Automate task of deploying web-apps (rails, node) to kubernetes on cloud service

# Issues /  ToDo
- Deployment should build the contents of dist and dist-server directories as
    part of deployment

- Deployment should not include the source code and other un-needed artifacts
    outside the dist and dist-server directories

- Use a random number in the docker_context and kubernetes_config directories
-   so that we detect failure to (re)build content

- Make sure successfully deploys contain expected / new contents
  by adding random id on newly constructed images

- Inconsistent use of hiding / exposing details within project, cloud, apps

- Partitioning into containerize and deploy

- Production, Test, Development specified in config

- Remote registry uri specified in config

- Cloud provider setup (meta to kubernetes) automated or at least described

- Deployment to cloud should likely be independent of containerizing apps

- Deployment to cloud should likely occur once not per app

- Only add key refrences to kubernetes deployment when actual key is specified in config

- Remove the app-secretes.yml file from kubernetes-config directory after apply

