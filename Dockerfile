FROM debian:stretch 
WORKDIR /tmp

# Install Google Cloud SDKbundle with all components and dependencies
# Dockerfile commands from https://hub.docker.com/r/google/cloud-sdk/dockerfile
ARG CLOUD_SDK_VERSION=229.0.0
ENV CLOUD_SDK_VERSION=$CLOUD_SDK_VERSION

ARG INSTALL_COMPONENTS=kubectl
RUN apt-get update -qqy && apt-get install -qqy \
curl \ 
gcc \ 
python-dev \ 
python-setuptools \ 
apt-transport-https \ 
lsb-release \ 
openssh-client \ 
git \ 
gnupg \ 
&& easy_install -U pip && \ 
pip install -U crcmod && \ 
export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \ 
echo "deb https://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" > /etc/apt/sources.list.d/google-cloud-sdk.list && \ 
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \ 
apt-get update && apt-get install -y google-cloud-sdk=${CLOUD_SDK_VERSION}-0 $INSTALL_COMPONENTS && \ 
gcloud config set core/disable_usage_reporting true && \ 
gcloud config set component_manager/disable_update_check true && \ 
gcloud config set metrics/environment github_docker_image && \ 
gcloud --version VOLUME ["/root/.config"] 

# Install Terraform
RUN apt-get install -qqy unzip && \
curl -O https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip && \
unzip terraform_0.11.11_linux_amd64.zip && \
install terraform /usr/local/bin/

# Install Helm
RUN curl -O https://storage.googleapis.com/kubernetes-helm/helm-v2.12.2-linux-amd64.tar.gz && \
tar -xzvf helm-v2.12.2-linux-amd64.tar.gz && \
install linux-amd64/tiller /usr/local/bin/ && \
install linux-amd64/helm /usr/local/bin/

# Install aws-iam-authenticator
RUN curl -O https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/linux/amd64/aws-iam-authenticator && \
install aws-iam-authenticator /usr/local/bin/

# Install terraform-provider-helm
RUN mkdir -p ~/.terraform.d/plugins
COPY /tmp/terraform-provider-helm ~/.terraform.d/plugins/

