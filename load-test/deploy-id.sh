#!/bin/sh

gcloud compute addresses create locust-master-id-ip \
    --region asia-southeast2

export ID_MASTER_IP=$(gcloud compute addresses describe locust-master-id-ip --format='get(address)' --region asia-southeast2)

gcloud compute instances create-with-container locust-master-id \
  --container-image gcr.io/eatn-production/load-test:latest \
  --container-privileged \
  --network eatn-network \
  --container-arg="--web-port" \
  --container-arg="80" \
  --container-arg="--master" \
  --container-arg="-f" \
  --container-arg="locustfile-id.py" \
  --subnet asia-southeast2-subnet \
  --tags http-server,locust \
  --zone asia-southeast2-a \
  --address=${ID_MASTER_IP}

export ID_MASTER_PRIVATE_IP=$(gcloud compute instances describe locust-master-id --format='get(networkInterfaces[0].networkIP)'  --zone asia-southeast2-a) 

gcloud compute instances create-with-container locust-worker-id-asia-southeast2-1 \
  --container-image gcr.io/eatn-production/load-test:latest \
  --container-privileged \
  --network eatn-network \
  --container-arg="--master-host" \
  --container-arg=${ID_MASTER_PRIVATE_IP} \
  --container-arg="--worker" \
  --container-arg="-f" \
  --container-arg="locustfile-id.py" \
  --subnet asia-southeast2-subnet \
  --zone asia-southeast2-a \
  --tags http-server,locust \
  --no-address

gcloud compute instances create-with-container locust-worker-id-asia-southeast1-1 \
  --container-image gcr.io/eatn-production/load-test:latest \
  --container-privileged \
  --network eatn-network \
  --container-arg="--master-host" \
  --container-arg=${ID_MASTER_PRIVATE_IP} \
  --container-arg="--worker" \
  --container-arg="-f" \
  --container-arg="locustfile-id.py" \
  --subnet asia-southeast1-subnet \
  --tags http-server,locust \
  --zone asia-southeast1-a \
  --no-address



# gcloud compute instances create-with-container locust-worker-id-asia-southeast2-2 \
#   --container-image gcr.io/eatn-production/load-test:latest \
#   --container-privileged \
#   --network eatn-network \
#   --container-arg="--master-host" \
#   --container-arg=${ID_MASTER_PRIVATE_IP} \
#   --container-arg="--worker" \
#   --container-arg="-f" \
#   --container-arg="locustfile-id.py" \
#   --subnet asia-southeast2-subnet \
#   --zone asia-southeast2-b \
#   --tags http-server,locust \
#   --no-address    

# gcloud compute instances delete locust-master-id
# gcloud compute instances delete locust-worker-id-asia-southeast2
# gcloud compute instances delete locust-worker-id-asia-southeast1


# gcloud compute instance-templates create-with-container locust-worker-id-asia-southeast2-template \
#   --container-image gcr.io/eatn-production/load-test:latest \
#   --container-privileged \  
#   --container-arg="--master-host" \
#   --container-arg=${ID_MASTER_PRIVATE_IP} \
#   --container-arg="--worker" \
#   --container-arg="-f" \
#   --container-arg="locustfile-id.py" \
#   --tags http-server,locust \
#   --no-address --network eatn-network --subnet asia-southeast2-subnet

# gcloud compute instance-groups managed create locust-worker-id-asia-southeast2 \
#     --base-instance-name locust-worker-id-asia-southeast2 \
#     --size 4 \
#     --template locust-worker-id-asia-southeast2-template \
#     --region asia-southeast2 \
#     --zones asia-southeast2-a,asia-southeast2-b,asia-southeast2-c


# gcloud compute instance-groups managed delete locust-worker-id-asia-southeast2
# gcloud compute instance-templates delete locust-worker-id-asia-southeast2-template
