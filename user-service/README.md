USER SERVICE
===


1. create bucket for storing user service artefact

```bash
$ gsutil mb gs://eatn-user-service
```

2. build artefact.
```
gcloud builds submit --substitutions=_DEPLOY_DIR=gs://eatn-user-service,_DEPLOY_FILENAME=app.tar.gz
```

3. copy startup script to gcs 

```
$ gsutil cp startup-script.sh gs://eatn-user-service/
```

