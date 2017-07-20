require './build_gce'
require './build_util'
require './build_docker'
require './build_kubernetes'
require 'ostruct'

project = OpenStruct.new
project.id   = 0
project.name = 'venteicher-org'
project.tag  = 'venteicher-org'
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
#registry  =  "gcr.io/#{project.id}/#{project.name}:#{project.tag}"
#
#image_uri =  "gcr.io/#{project.id}/#{project.name}:latest"
#image_uri = "#{external_registry_endpoint}#{project.name}"
#image_uri = "gcr.io/#{project.id}/#{project.name}:#{project.image_uri}"

# docker run -d -p 5000:5000 --name registry registry:2

#exec 'rails new venteicher-org-git --force'

image_uri = "venteicher-org"
image_uri = "gcr.io/venteicher-org-174023/venteicher-org"
docker_context_url = "docker_context"

docker_create_container_image(image_uri, docker_context_url)

gce_push_container_image(image_uri)

# Start local docker registry
# docker run -d -p 5000:5000 --name registry registry:2

#external_registry_endpoint = "localhost:5000/"
#exec "docker push #{external_registry_endpoint}#{project.name}"

kubernetes_delete_old()


kubernetes_config_url = "kubernetes_config"

puts "input rails_master_key:"
rails_master_key = gets.chomp

puts "your key is #{rails_master_key}"


kubernetes_establish_app_secrets_yml(kubernetes_config_url, rails_master_key)


# Deploy the replicated back end for the application.
#
#component = OpenStruct.new
#component.app = "venteicher-org"
#component.tier  = "worker"
#component.replicas = 2
#kubernetes_establish_deployment(component, image_uri)


# Deploy the replicated front end for the application.
#
component = OpenStruct.new
component.app = "venteicher-org"
component.tier  = "frontend"
component.replicas = 3

kubernetes_establish_deployment(component, image_uri, kubernetes_config_url)

# Deploy the load-balanced service to route HTTP traffic to the front end.
#
service = OpenStruct.new
service.app = "venteicher-org"
service.tier  = "frontend"
kubernetes_establish_service(service, component, kubernetes_config_url)

# To see app on minikube do this
# minikube service venteicher-org-load-balancer




