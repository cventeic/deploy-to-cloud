require 'erb'

def misc_abc
  #exec("kubectl get deployments")
  #exec("kubectl get pods")

  # Delete deployment
  # exec("kubectl delete deployments #{deployment.name}")
end

def kubernetes_delete_old()
  exec("kubectl delete service --all")
  exec("kubectl delete deployment --all")
end

def kubernetes_establish_deployment(component, image, kubernetes_config_url)

  component_name = "#{component.app}-#{component.tier}"

  deployment = %{
    # This file configures the application frontend. 
    # The frontend serves public web traffic.

    apiVersion: extensions/v1beta1
    kind: Deployment
    metadata:
      name: #{component_name}
      labels:
        app: #{component.app}
        tier: #{component.tier} 

    # The replica set ensures that at least 3
    # instances of the app are running on the cluster.
    # For more info about Pods see:
    #   https://cloud.google.com/container-engine/docs/pods/
    spec:
      replicas: #{component.replicas}
      template:
        metadata:
          labels:
            app: #{component.app}
            tier: #{component.tier}
        spec:
          containers:
          - name: #{component_name}

            image: #{image}:latest

            # This setting makes nodes pull the docker image every time before
            # starting the pod. This is useful when debugging, but should be turned
            # off in production.
            imagePullPolicy: Always

            #imagePullPolicy: IfNotPresent

            # The FORMATION environment variable is used by foreman in the
            # Dockerfile's CMD to control which processes are started. In this
            # case, only the bookshelf process is needed.
            # - name: FORMATION
            #   value: web=1

            env:
            - name: RAILS_MASTER_KEY
              valueFrom:
                secretKeyRef:
                  name: app-secrets
                  key: rails_master_key

            # The process listens on port 8080 for web traffic by default.
            # containerPort: 8080
            # containerPort: 3000   # Rails
            ports:
              - name: rails-server
                containerPort: 3000
              - name: http-server
                containerPort: 8080
   }

  #<%= if (component.tier == "frontend") %>
  #<% end %>

  exec("mkdir -p #{kubernetes_config_url}")

  file_name = "#{kubernetes_config_url}/deployment-#{component_name}.yaml"

  file_txt  = ERB.new(deployment).result()

  make_file(file_name, file_txt)

  exec("kubectl create -f #{file_name}")
end

def kubernetes_establish_app_secrets_yml(kubernetes_config_url, rails_master_key)

  # mysql_user: cm9vdA==
  # mysql_password: bXkgc2VjdXJlIHBhc3N3b3Jk

  app_secrets_yml = %{
    apiVersion: v1
    data:
      rails_master_key: #{rails_master_key}
    kind: Secret
    type: Opaque
    metadata:
      name: app-secrets
  }

  exec("mkdir -p #{kubernetes_config_url}")

  file_name = "#{kubernetes_config_url}/app-secrets.yml"

  make_file(file_name, ERB.new(app_secrets_yml).result())

  #exec("kubectl create -f #{file_name}")
  exec("kubectl apply -f #{file_name}")

  exec("rm -f #{file_name}") # Don't keep this around

 end

def kubernetes_establish_service(service, component, kubernetes_config_url)

  service_name = "#{service.app}-load-balancer"

  service_yml = %{

    # The service provides a load-balancing proxy over the frontend pods. 
    # By specifying the type as a 'LoadBalancer', Container Engine will create an external HTTP load balancer.
    # For more information about Services see:
    #   https://cloud.google.com/container-engine/docs/services/
    # For more information about external HTTP load balancing see:
    #   https://cloud.google.com/container-engine/docs/load-balancer
    kind: Service
    apiVersion: v1
    metadata:
      name: #{service_name}
      labels:
        app: #{service_name}
        tier: #{service.tier}
    spec:
      type: LoadBalancer
      selector:
        app: #{component.app}
        tier: #{component.tier}
      ports:
      - port: 80
        targetPort: http-server
  }

  exec("mkdir -p #{kubernetes_config_url}")

  file_name = "#{kubernetes_config_url}/service-#{service_name}.yaml"

  make_file(file_name, ERB.new(service_yml).result())

  exec("kubectl create -f #{file_name}")

  # exec("kubectl describe service #{service_name}")
end


