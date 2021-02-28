USER SERVICE
===


1. create bucket for storing user service artefact

```bash
$ gsutil mb gs://gcp-ha-demo-user-service-artefact
```

2. build artefact.
```
gcloud builds submit --substitutions=_DEPLOY_DIR=gs://gcp-ha-demo-user-service-artefact,_DEPLOY_FILENAME=app.tar.gz
```

3. copy startup script to gcs 

```
$ gsutil cp startup-script.sh gs://gcp-ha-demo-user-service-artefact/
```

3. create instance template:
```

ZONE=us-central1-a

gcloud compute instances create test-user-service \
    --image-family=debian-10 \
    --image-project=debian-cloud \
    --machine-type=g1-small \
    --scopes userinfo-email,cloud-platform \
    --metadata-from-file startup-script=startup-script.sh \
    --metadata app-location="gs://gcp-ha-demo-user-service-artefact/app.tar.gz" \
    --zone us-central1-a \
    --tags http-server

gcloud compute firewall-rules create default-allow-http-80 \
    --allow tcp:80 \
    --source-ranges 0.0.0.0/0 \
    --target-tags http-server \
    --description "Allow port 80 access to http-server" 




restart instance group:

