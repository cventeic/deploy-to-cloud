# Google Container Setup


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


