#!/bin/sh

gcloud compute addresses create locust-master-us-ip \
    --region us-central1
    
export US_MASTER_IP=$(gcloud compute addresses describe locust-master-us-ip --format='get(address)' --region us-central1)

gcloud compute instances create-with-container locust-master-us \
  --container-image gcr.io/eatn-production/load-test:latest \
  --container-privileged \
  --network eatn-network \
  --container-arg="--web-port" \
  --container-arg="80" \
  --container-arg="--master" \
  --container-arg="-f" \
  --container-arg="locustfile-us.py" \
  --subnet us-central1-subnet \
  --tags http-server,locust \
  --zone us-central1-a \
  --address=${US_MASTER_IP}

export US_MASTER_PRIVATE_IP=$(gcloud compute instances describe locust-master-us --format='get(networkInterfaces[0].networkIP)'  --zone us-central1-a)

gcloud compute instances create-with-container locust-worker-us-central1 \
  --container-image gcr.io/eatn-production/load-test:latest \
  --container-privileged \
  --network eatn-network \
  --container-arg="--master-host" \
  --container-arg=${US_MASTER_PRIVATE_IP} \
  --container-arg="--worker" \
  --container-arg="-f" \
  --container-arg="locustfile-us.py" \
  --subnet us-central1-subnet \
  --zone us-central1-a \
  --tags http-server,locust \
  --no-address

gcloud compute instances create-with-container locust-worker-us-west1 \
  --container-image gcr.io/eatn-production/load-test:latest \
  --container-privileged \
  --network eatn-network \
  --container-arg="--master-host" \
  --container-arg=${US_MASTER_PRIVATE_IP} \
  --container-arg="--worker" \
  --container-arg="-f" \
  --container-arg="locustfile-us.py" \
  --subnet us-west1-subnet \
  --tags http-server,locust \
  --zone us-west1-a \
  --no-address

gcloud compute instances delete locust-master-us
gcloud compute instances delete locust-worker-us-1
gcloud compute instances delete locust-worker-us-2

