require 'erb'

# Kubernetes services...
# Think micro-service available to all pods
#
# Service defines a logical set of Pods and a policy by which to access them
#
# The set of Pods is (usually) determined by a Label Selector.
#
# More info: http://kubernetes.io/docs/user-guide/services#defining-a-service
# More info: http://kubernetes.io/docs/user-guide/services#virtual-ips-and-service-proxies
#


def misc_abc
  #exec("kubectl get deployments")
  #exec("kubectl get pods")

  # Delete deployment
  # exec("kubectl delete deployments #{deployment.name}")
end

# Todo: Make this selective
def kubernetes_delete_old()
  exec("kubectl delete service --all")
  exec("kubectl delete deployment --all")
  exec("kubectl delete ingress --all")
  exec("kubectl delete hpa --all")
end

def kubernetes_establish_app_secrets_yml(config_directory, keys)
  puts "#{__method__.to_s} enter"

  # example:   rails_master_key: #{rails_master_key}
  #
  keys_strings = []
  keys.to_h.each_pair do |key_id, key_value|
    keys_strings << "#{key_id}: #{key_value}"
  end

  puts "keys_strings: #{keys_strings}"


  app_secrets_yml = %{
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
type: Opaque
data:
  username: YWRtaW4=
  password: MWYyZDFlMmU2N2Rm
  #{keys_strings.join('\n')}
}


  exec("rm -r -f #{config_directory}")
  exec("mkdir -p #{config_directory}")

  file_name = "#{config_directory}/app-secrets.yml"

  make_file(file_name, ERB.new(app_secrets_yml).result())

  exec("kubectl apply -f #{file_name}")

  exec("rm -f #{file_name}") # Don't keep a file with secret keys hanging around

  puts "#{__method__.to_s} exit"
end


def kubernetes_apply(config_directory: '', uber_name: 'venteicher-org', replicas: 1, docker_image_name:)
  puts "#{__method__.to_s} enter"


  service_port  = "k-srv-port"           # URI for port exposed by service needed by ingress

  deployments_port  = "w-srvr-port"     # URI for port exposed by web server

  # ingress annotations:
  #  kubernetes.io/ingress.global-static-ip-name: venteicher-org-ip

  yml = %{
# This file configures the application frontend.
# The frontend serves public web traffic.

apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: deployment-#{uber_name}
  labels:
    app: deployment-#{uber_name}

spec:
  template:
    metadata:
      labels:
        app: deployment-#{uber_name}
    spec:
      containers:
      # Environment variables to set in controller
      - env:
        - name: RAILS_MASTER_KEY
          valueFrom:
            secretKeyRef:
              key: rails_master_key
              name: app-secrets

        # Docker image name
        image: #{docker_image_name}

        # Image pull policy.
        # One of Always, Never, IfNotPresent. Defaults to Always if :latest tag is specified, or IfNotPresent otherwise.
        # This setting makes nodes pull the docker image every time before starting the pod.
        # This is useful when debugging, but should be turned off in production.
        imagePullPolicy: IfNotPresent

        #imagePullPolicy: Always

        # Name of the container specified as a DNS_LABEL.
        # Each container in a pod must have a unique name
        name: #{uber_name}

        # List of ports exposed from the container
        ports:
        # Name for the port that can be referred to by services.
        - name: #{deployments_port}
          # Port exposed from container
          containerPort: 8080

---

apiVersion: v1
kind: Service

metadata:
  name: service-#{uber_name}

spec:
  # NodePort: Exposes the service on each Node’s IP at a static port (the NodePort).
  type: NodePort

  # Deliver service using pods matching this label
  selector:
    app: deployment-#{uber_name}

  ports:
  - name: #{service_port}
    port: 8080

    # Number or name of the port to access on the pods targeted by the service.
    # A string will be looked up as a named port in the target Pod's container ports.
    targetPort: #{deployments_port}

---


apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress-#{uber_name}
  annotations:
    kubernetes.io/ingress.global-static-ip-name: venteicher-org-ip

spec:
  backend:
    serviceName: service-#{uber_name}
    servicePort: #{service_port}

---

# Autoscaler
# Creates new pods on nodes in response to demand
# GCE creates new nodes as needed


apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: hpa-venteicher-org
spec:
  maxReplicas: 10
  minReplicas: 1
  scaleTargetRef:
    apiVersion: extensions/v1beta1
    kind: Deployment
    name: deployment-venteicher-org
  targetCPUUtilizationPercentage: 50

}

  exec("mkdir -p #{config_directory}")

  file_name = "#{config_directory}/#{uber_name}.yaml"

  make_file(file_name, ERB.new(yml).result())

  exec("kubectl apply -f #{file_name}")

  puts "#{__method__.to_s} exit"
end









