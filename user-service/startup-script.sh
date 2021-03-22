#! /bin/sh

set -ex

curl -s "https://storage.googleapis.com/signals-agents/logging/google-fluentd-install.sh" | bash
service google-fluentd restart &

export POSTGRES_DB=user-service
export POSTGRES_USER=user-service
export POSTGRES_PASSWORD=password01
export POSTGRES_HOST=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/postgres-host" -H "Metadata-Flavor: Google")
export POSTGRES_REPLICA_HOSTS=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/postgres-replica-hosts" -H "Metadata-Flavor: Google")

APP_LOCATION=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/app-location" -H "Metadata-Flavor: Google")
gsutil cp "$APP_LOCATION" app.tar.gz
tar -xzf app.tar.gz

service my-app start