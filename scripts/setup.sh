echo "===================================================="
echo " Setting up environment variables ..."

# GCP
export PROJECT_ID=""
export REGION=""
export SERVICE_BUCKET=gs://${PROJECT_ID}-${REGION}-services

# reddit
export REDDIT_CLIENT_ID=""
export REDDIT_CLIENT_SECRET=""
export REDDIT_USERNAME=""
export REDDIT_PASSWORD=""

echo "===================================================="
echo " Enabling services ..."

gcloud config set project $PROJECT_ID

gcloud services enable storage-component.googleapis.com 
gcloud services enable compute.googleapis.com  
gcloud services enable servicenetworking.googleapis.com 
gcloud services enable iam.googleapis.com 
gcloud services enable cloudbilling.googleapis.com
gcloud services enable bigquery.googleapis.com
gcloud services enable dataflow.googleapis.com
gcloud services enable pubsub.googleapis.com

echo "===================================================="
echo " Make GCS bucket ..."

gsutil mb -c standard -l $REGION $SERVICE_BUCKET

echo "===================================================="
echo " Setting external IP access ..."

echo "{
  \"constraint\": \"constraints/compute.vmExternalIpAccess\",
	\"listPolicy\": {
	    \"allValues\": \"ALLOW\"
	  }
}" > external_ip_policy.json

gcloud resource-manager org-policies set-policy external_ip_policy.json --project=$PROJECT_ID

cd terraform

# edit the variables.tf
sed -i "s|%%PROJECT_ID%%|$PROJECT_ID|g" sample.tfvars
sed -i "s|%%REDDIT_CLIENT_ID%%|$REDDIT_CLIENT_ID|g" sample.tfvars
sed -i "s|%%REDDIT_CLIENT_SECRET%%|$REDDIT_CLIENT_SECRET|g" sample.tfvars
sed -i "s|%%REDDIT_USERNAME%%|$REDDIT_USERNAME|g" sample.tfvars
sed -i "s|%%REDDIT_PASSWORD%%|$REDDIT_PASSWORD|g" sample.tfvars

terraform init
terraform plan -var-file=sample.tfvars
terraform apply -var-file=sample.tfvars