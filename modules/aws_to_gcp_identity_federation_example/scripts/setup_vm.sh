#!/bin/bash

install_g_cloud () {

    # Install gcloud
    sudo tee -a /etc/yum.repos.d/google-cloud-sdk.repo << EOM
[google-cloud-cli]
name=Google Cloud CLI
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el8-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM

    sudo yum install libxcrypt-compat.x86_64

    sudo yum install google-cloud-cli -y

}

install_g_cloud

# Grab file form bucket
aws configure set aws_access_key_id "${aws_access_key_id}"
aws configure set aws_secret_access_key "${aws_secret_access_key}" 
aws configure set region "${region}"

aws s3api get-object --bucket gcp-to-aws-identity-federation --key workload_identity_pool_config.json workload_identity_pool_config.json


echo "export AWS_ACCESS_KEY_ID=${aws_access_key_id}" | sudo tee -a /etc/profile
echo "export AWS_SECRET_ACCESS_KEY=${aws_secret_access_key}" | sudo tee -a /etc/profile
echo "export AWS_REGION=${region}" | sudo tee -a /etc/profile
