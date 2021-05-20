#! /bin/sh

set -ex

# apt update
# apt -y upgrade
apt install -y python3-venv python3-pip git
pip3 install locust

git clone https://github.com/imrenagi/gcp-high-availability-demo.git
cd gcp-high-availability-demo/load-test
pip3 install -r requirements.txt

locust --master --web-port 80