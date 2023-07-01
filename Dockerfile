
FROM ubuntu:latest

RUN apt-get update -y

RUN apt-get install unzip -y
RUN apt-get install wget -y
RUN apt-get install curl -y
RUN apt-get install python-is-python3 -y
RUN apt-get -y install git
RUN apt-get install python3-pip -y
RUN yes | pip install requests

# Download terraform for linux
RUN wget https://releases.hashicorp.com/terraform/1.3.6/terraform_1.3.6_linux_amd64.zip

# Unzip
RUN unzip terraform_1.3.6_linux_amd64.zip

# Move to local bin
RUN mv terraform /usr/local/bin/

# Downloading gcloud package
RUN curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz

# Installing the package
RUN mkdir -p /usr/local/gcloud 
RUN tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz
RUN /usr/local/gcloud/google-cloud-sdk/install.sh

# Adding the package path to local
ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install

RUN apt-get -y install nano

RUN apt-get install golang-go -y