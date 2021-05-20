#!/bin/sh

gcloud compute addresses create locust-master-ip \
    --region asia-southeast2
    
export MASTER_IP=$(gcloud compute addresses describe locust-master-ip --format='get(address)' --region asia-southeast2)

gcloud compute instances create-with-container locust-master \
  --container-image gcr.io/eatn-production/load-test:latest \
  --container-privileged \
  --network eatn-network \
  --container-arg="--web-port" \
  --container-arg="80" \
  --container-arg="--master" \
  --subnet asia-southeast2-subnet \
  --tags http-server,locust \
  --address=${MASTER_IP}

gcloud compute instances create-with-container locust-worker \
  --container-image gcr.io/eatn-production/load-test:latest \
  --container-privileged \
  --network eatn-network \
  --container-arg="--master-host" \
  --container-arg="34.101.161.14" \
  --container-arg="--worker" \
  --subnet asia-southeast2-subnet \
  --tags http-server,locust

gcloud compute instances create-with-container locust-worker-2 \
  --container-image gcr.io/eatn-production/load-test:latest \
  --container-privileged \
  --network eatn-network \
  --container-arg="--master-host" \
  --container-arg=${MASTER_IP} \
  --container-arg="--worker" \
  --subnet us-central1-subnet \
  --zone us-central1-a \
  --tags http-server,locust  
  
--worker --host eatn.imrenagi.com --master-host 127.0.0.1


gcloud compute instances add-tags locust-master --tags http-server,locust

gcloud compute instances delete locust-master
gcloud compute instances delete locust-worker
gcloud compute instances delete locust-worker-2

