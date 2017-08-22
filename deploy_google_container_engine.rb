=begin

#####################################
#
xxx = <<-YML
gcloud container node-pools create db-pool \
    --machine-type=n1-highmem-2 \
    --num-nodes=1 \
    --cluster=rails
YML

# Reserve static IP address from google cloud
'gcloud compute addresses create app-external — region=us-central1'

# Create disk
'gcloud compute disks create --size 300GB --type pd-ssd db-data'

# container image format in google docker repository
'docker tag app us.gcr.io/$PROJECT_ID/$CONTAINER_NAME:$TAG'

# Installing kubectl
'gcloud components install kubectl'

=end


#########
# 1. Create Container Engine Cluster
#
def gce_create_cluster(project)

  create_gce_cluster = <<-YML
gcloud container clusters create #{project.name}\
    --enable-cloud-logging \
    --enable-cloud-monitoring \
    --machine-type n1-standard-2 \
    --num-nodes 1
  YML

  exec(create_gce_cluster)

  exec("gcloud container clusters get-credentials #{project.name}")

  project.credentials = ""
end

#########
# 2. Creating a Cloud Storage Bucket
#
def gcs_create_bucket(bucket_name)

  # Create a bucket
  exec("gsutil mb gs://#{bucket_name}")

  # Set the bucket's default ACL to public-read, 
  # which enables users to see their uploaded images:
  exec("gsutil defacl set public-read gs://#{bucket_name}")

  # Creating Cloud Storage access keys
  # 1. Open the Cloud Storage Settings.
  # 2. In the menu at the top, click Interoperability.
  # 3. Click Create a new key.
  # 4. Note the Access Key and Secret because they will be used in the application configuration.

end

