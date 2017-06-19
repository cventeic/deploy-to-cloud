require './build_gce'
require './build_util'
require './build_docker'
require './build_kubernetes'
require 'ostruct'

project = OpenStruct.new
project.id   = 0
project.name = 'test-app'
project.tag  = 'test-app'
# project.gcs_bucket_name = ''
# project.access_key = ''
# project.secret = ''

# 1. Create Container Engine Cluster
#gce_create_cluster(project)

# 2. Creating a Cloud Storage bucket
#gcs_create_bucket(project.gcs_bucket_name)

# 3. Containerize a Ruby application.
#
#   a. Cloning/Create the sample application
#
#   b. Configuring the application
#rails_configure_db(project.id)
#rails_configure_settings(project)

#   c. Containerizing the application
#image_tag =  "gcr.io/#{project.id}/#{project.name}:#{project.tag}"
#image_url =  "gcr.io/#{project.id}/#{project.name}:latest"

#registry  =  "gcr.io/#{project.id}/#{project.name}:#{project.tag}"

# docker run -d -p 5000:5000 --name registry registry:2


#image_tag =  "#{registry}:#{project.tag}"
#image_tag =  "#{registry}:latest"
#image_url =  "gcr.io/#{project.id}/#{project.name}:latest"

#
#exec 'rails new test-app-git --force'

#external_registry_endpoint  = "localhost:5000/"
#image_url = "#{external_registry_endpoint}#{project.name}"

image_url = "test-app"
docker_context_url = "docker_context"

#container_name = "gcr.io/#{project.id}/#{project.name}:#{project.container_name}"
container_name = "test-app"

docker_create_container_image(container_name, docker_context_url)

#gce_push_container_image(image_tag)

# Start local docker registry
# docker run -d -p 5000:5000 --name registry registry:2

#external_registry_endpoint = "localhost:5000/"
#exec "docker push #{external_registry_endpoint}#{project.name}"

kubernetes_delete_old()

# Deploy the replicated back end for the application.
#
#component = OpenStruct.new
#component.app = "test-app"
#component.tier  = "worker"
#component.replicas = 2
#kubernetes_establish_deployment(component, image_url)


# Deploy the replicated front end for the application.
#
component = OpenStruct.new
component.app = "test-app"
component.tier  = "frontend"
component.replicas = 3

kubernetes_config_url = "kubernetes_config"
kubernetes_establish_deployment(component, image_url, kubernetes_config_url)

# Deploy the load-balanced service to route HTTP traffic to the front end.
#
service = OpenStruct.new
service.app = "test-app"
service.tier  = "frontend"
kubernetes_establish_service(service, component, kubernetes_config_url)

# To see app on minikube do this
# minikube service test-app-load-balancer




