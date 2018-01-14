note: you likely still need to do yarn build all in web site directory before
deploying


# mapping static ip address
- Allocate a static ip address withing the google cloud configuration tools.
    Console-> VPC network -> External IP Address
    Change external address type form Ephemeral to Static
    Set name to venteicher-org-ip
      (venteicher-org-ip is what the kubernetes ingress is configured to look for)

- Map the DNS provider to send venteicher.org to that static IP address.






# Google Container Setup

1. Create project

2. Go to GUI for container engine and create cluster
   Select advanced opitions and select autoscaling and preemption

   Probably need to create this way first...
      gcloud container clusters create example-cluster-name --scopes https://www.googleapis.com/auth/cloud_debugger


gcloud beta container --project "venteicher-org-174023" clusters create "venteicher-org-cluster-1" --zone "us-central1-a" --username="admin" --cluster-version "1.7.5-gke.1" --machine-type "g1-small" --image-type "COS" --disk-size "100" --scopes "https://www.googleapis.com/auth/compute","https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append","https://www.googleapis.com/auth/cloud_debugger"  --preemptible --num-nodes "1" --network "default" --enable-cloud-logging --enable-cloud-monitoring --subnetwork "default" --enable-autoscaling --enable-legacy-authorization  --min-nodes "1" --max-nodes "5" --enable-autoupgrade --enable-autorepair


3.  Download kubectl credentials and ready kubectl to use the cluster

    gcloud container clusters get-credentials <cluster-name>

4.  Log in to the kubernetes ui...  http://localhost:8001/ui



## alternate


2. Configure gcloud commands to use project

    gcloud config set project venteicher-org-174023


3. Create compute engine VM instance template and instance group

   Potentially this is an independent step but step 4 seems to combine the VM
   level with the container level
   and then you neeed to go back to compute engine interface and deal with
   instance template and group as indicated below


4. Create a container cluster

    gcloud container clusters create <cluster-name> --machine-type f1-micro --enable-autoupgrade

    gcloud container clusters create example-cluster-name --scopes https://www.googleapis.com/auth/cloud_debugger

    Through the gui I set premptible and autoscaling 1->3


    3.1 select instance template

    3.2 create instance group


## Set defaults for the gcloud command-line tool

gcloud config set project PROJECT_ID
gcloud config set project venteicher-org-174023

gcloud config set compute/zone us-central1     (IOWA)
gcloud config set compute/zone us-central1




List clusters available to gcloud:
  gcloud container clusters list

Ensure kubectl has the right credentials:
  gcloud auth application-default login

  This opens browser and lets you select credentials


Configure gcloud for the correct project:
  gcloud config set project venteicher-org-174023

Enable container engine for the project:
  enabled in the Google Cloud Console at https://console.cloud.google.com/apis/api/container.googleapis.com/overview?project=venteicher-org-174023

Enable compute engine for the project:
  https://console.developers.google.com/apis/api/compute-component.googleapis.com/overview?project=venteicher-org-174023&pli=1

Create the cluster:
  gcloud container clusters create venteicher-org-cluster --scopes "cloud-platform,userinfo-email" --machine-type f1-micro --num-nodes 3

    Creating cluster venteicher-org-cluster-18...done.
    Created [https://container.googleapis.com/v1/projects/venteicher-org-174023/zones/us-central1-c/clusters/venteicher-org-cluster-18].
    kubeconfig entry generated for venteicher-org-cluster-18.
    NAME                       ZONE           MASTER_VERSION  MASTER_IP     MACHINE_TYPE  NODE_VERSION  NUM_NODES  STATUS
    venteicher-org-cluster-18  us-central1-c  1.6.4           35.188.21.60  f1-micro      1.6.4         3          RUNNING

  options:
    enabled by default:
      --enable-cloud-logging --enable-cloud-monitoring 
    other:
      --machine-type f1-micro --num-nodes 3

  Through the gui I set premptible and autoscaling 1->3

  Current cluster is venteicher-org-cluster-aug17




  scopes:
  - cloud-platform: View and manage your data across Google Cloud Platform Services
  - userinfo-email: View your email address


Download kubectl credentials and ready kubectl:
  gcloud container clusters get-credentials venteicher-org-july19

    Fetching cluster endpoint and auth data.
    kubeconfig entry generated for venteicher-org-cluster.

    http://localhost:8001/ui

Check Status:
  kubectl cluster-info
    Kubernetes master is running at https://35.188.80.253
    GLBCDefaultBackend is running at https://35.188.80.253/api/v1/namespaces/kube-system/services/default-http-backend/proxy
    Heapster is running at https://35.188.80.253/api/v1/namespaces/kube-system/services/heapster/proxy
    KubeDNS is running at https://35.188.80.253/api/v1/namespaces/kube-system/services/kube-dns/proxy
    kubernetes-dashboard is running at https://35.188.80.253/api/v1/namespaces/kube-system/services/kubernetes-dashboard/proxy

  kubectl config current-context
    gke_venteicher-org-174023_us-central1-c_venteicher-org-cluster


