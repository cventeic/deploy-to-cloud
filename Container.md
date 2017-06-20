
https://www.linode.com/docs/web-servers/nginx/how-to-configure-nginx


# Minicube
- Starting minicube will auto start any services and deployments that were
    prevously loaded (configuration persistence)


# Start minikube
minikube start

# Get status dashboard
minikube dashboard

# Make shell use right docker environment for minikube
eval (minikube docker-env)

# Access web page
minikube service test-app-load-balancer --url

