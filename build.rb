require './build_gce'
require './build_util'

project = {
  id: 0,
  name: 'test_app',
  tag: '',
  gcs_bucket_name: '',
  access_key: '',
  secret: ''
}

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
image_tag =  "gcr.io/#{project.id}/#{project.name}:#{project.tag}"
image_url =  "gcr.io/#{project.id}/#{project.name}:latest"

exec 'rails new test_app --force'

docker_create_container_image(image_tag)
#gce_push_container_image(image_tag)


# Deploy the replicated front end for the application.
#
component.app = "bookshelf"
component.tier  = "frontend"
component.replicas = 3
kubernetes_establish_deployment(component, image_url)

# Deploy the replicated back end for the application.
#
component.app = "bookshelf"
component.tier  = "worker"
component.replicas = 2 
kubernetes_estabish_deployment(component, image_url)

# Deploy the load-balanced service to route HTTP traffic to the Bookshelf front end.
#
service.app = "bookshelf"
service.tier  = "frontend"
kubernetes_establish_service(service)






