
# Start minikube
minikube start

# Get status dashboard
minikube dashboard

# Make shell use right docker environment for minikube
eval (minikube docker-env)

# Access web page
minikube service test-app-load-balancer --url

