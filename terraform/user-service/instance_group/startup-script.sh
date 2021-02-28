#! /bin/sh

set -ex

curl -s "https://storage.googleapis.com/signals-agents/logging/google-fluentd-install.sh" | bash
service google-fluentd restart &

APP_LOCATION=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/app-location" -H "Metadata-Flavor: Google")
gsutil cp "$APP_LOCATION" app.tar.gz
tar -xzf app.tar.gz

service my-app start
