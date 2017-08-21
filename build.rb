require './build_gce'
require './build_util'
require './build_docker'
require './build_kubernetes'
require 'ostruct'
require 'recursive_open_struct'

# def containerize( project_name: '', project_id: 0, compute_engine: '', app_types: [], app_source_directories: [])
def containerize(
    project_name: '',
    project_id: 0,
    app: {}
  )

  puts "#{__method__.to_s} enter"

  # Where to push the docker image
  #docker_remote_registry_uri = ""
  #docker_remote_registry_uri = "localhost:5000" if server.compute_engine == 'minikube'
  #docker_remote_registry_uri = "gcr.io/#{project_name}-#{project_id}" if server.compute_engine == 'gce'


  app_name       = "#{project_name}-#{project_id}"
  image_name     = "#{project_name}-#{project_id}"


  docker_context_directory = docker_ready_context_directory(
    app_name: app_name,
    app_source_directory: app.source_url
  )

  passenger_prep(container_context_directory: docker_context_directory, app_types: app.type)

  dockerfile_contents = docker_ready_dockerfile(app_directory: app_name, app_types: app.type)

  make_file("#{docker_context_directory}/Dockerfile", dockerfile_contents)



  docker_create_container_image(image_name: image_name, context_directory: docker_context_directory)

  container_info = { image_name: image_name }

  puts "#{__method__.to_s} exit"

  # Convert data structure (hashes and arrays) into a
  #   dot notation accessable structure (ex. config.project.name)
  #
  return RecursiveOpenStruct.new(container_info, recurse_over_arrays: true )

end

def push_container_image_to_cloud( local_image_name:'', cloud_config: {})
  puts "#{__method__.to_s} enter"

  puts "cloud_config: #{cloud_config}"

  docker_remote_image_uri = "#{cloud_config.registry_uri}/#{local_image_name}"

  docker_tag_image_into_repository(local_image_name, cloud_config.registry_uri)


  if cloud_config.provider == 'gce'

    # Google Container Engine
    gce_push_container_image(docker_remote_image_uri)

  else

    # Prior to this push, Start local docker registry hosted by docker:
    #   docker run -d -p 5000:5000 --name registry registry:2
    #   docker start registry

    exec "docker push #{docker_remote_image_uri}"
  end

  puts "#{__method__.to_s} exit"

  cloud_info = { remote_registry_image_uri: docker_remote_image_uri }

  # Convert data structure (hashes and arrays) into a
  #   dot notation accessable structure (ex. config.project.name)
  #
  return RecursiveOpenStruct.new(cloud_info, recurse_over_arrays: true )

end

def kubernetes( uber_name: '', keys: {}, remote_image_uri: '')
  puts "#{__method__.to_s} enter"

  kubernetes_delete_old()

  # Directory where the intermediate kubernetes config file are stored
  kubernetes_config_directory = "kubernetes_config"

  kubernetes_establish_app_secrets_yml(kubernetes_config_directory, keys)

  kubernetes_apply(
    config_directory: kubernetes_config_directory,
    uber_name: uber_name,
    docker_image_name: remote_image_uri
  )

  puts "#{__method__.to_s} exit"
end



require './config'

meta_config = get_config()

# 1. Prep Cloud Provider
#
# 1.a Create Container Engine Cluster
#     gce_create_cluster(project)
#
# 1.b Creating a Cloud Storage bucket
#     gcs_create_bucket(project.gcs_bucket_name)
#
# 2. Containerize Web Apps (Create Docker Image Locally)
#
# 3. Deploy to cloud
#
# 3.a Push images to cloud provider (or local)
# 3.b Deploy apps on cloud compute via kubernetes
#

def  deploy_to_cloud(project_config: {}, cloud_config: {}, local_image_name: '')
  puts "#{__method__.to_s} enter"

  cloud_info = push_container_image_to_cloud(
                cloud_config: cloud_config,
                local_image_name: local_image_name,
              )


  kubernetes(
    uber_name: project_config.name,
    keys:      project_config.keys,
    remote_image_uri: cloud_info.remote_registry_image_uri
  )

  puts "#{__method__.to_s} exit"
end

meta_config.apps.each do |app_config|

  puts "meta_config: #{meta_config}"

  container_info = containerize(
                      project_name: meta_config.project.name,
                      project_id: meta_config.project.id,
                      app: app_config
                    )


  deploy_to_cloud(
    project_config: meta_config.project,
    local_image_name: container_info.image_name,
    cloud_config: meta_config.cloud
  )
end


# Issues:
# - Make sure successfully deplopys contain expected / new contents
#   by adding random id on newly constructed images
# - Inconsistent use of hiding / exposing details within project, cloud, apps
# - Partitioning into containerize and deploy
# - Production, Test, Development specified in config
# - Remote registry uri specified in config
# - Cloud provider setup (meta to kubernetes) automated or at least described
# - Deployment to cloud should likely be independent of containerizing apps
# - Deployment to cloud should likely occur once not per app
# - Only add key refrences to kubernetes deployment when actual key is specified in config
# - Remove the app-secretes.yml file from kubernetes-config directory after apply

