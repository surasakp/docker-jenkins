FROM jenkins/jenkins:2.138
MAINTAINER Hardwire Interactive

# Suppress apt installation warnings
ENV DEBIAN_FRONTEND=noninteractive

# Change to root user
USER root

# Used to set the docker group ID
# Set to 497 by default, which is the group ID used by AWS Linux ECS Instance
ARG DOCKER_GID=497

# Create Docker Group with GID
# Set default value of 497 if DOCKER_GID set to blank string by Docker Compose
RUN groupadd -g ${DOCKER_GID:-497} docker

# workaround for mac
RUN gpasswd -a jenkins staff

# Used to control Docker and Docker Compose versions installed
ARG DOCKER_ENGINE=18.03.1~ce
ARG DOCKER_COMPOSE=1.21.2

# Install base packages
RUN apt-get update -y && apt-get install -y \
    apt-transport-https \
    curl \
    ca-certificates \
    gnupg2 \
    software-properties-common \
    python-dev \
    python-setuptools \
    gcc \
    make \
    libssl-dev \
    vim && \
    easy_install pip

# Install docker ce
RUN curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add - && \
    add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
        $(lsb_release -cs) \
        stable" && \
    apt-get update && \
    apt-get install -y docker-ce=${DOCKER_ENGINE:-18.03.1~ce}-0~debian && \
    usermod -aG docker jenkins && \
    usermod -aG users jenkins

# Install Docker Compose
RUN pip install docker-compose==${DOCKER_COMPOSE:-1.21.2} && \
    pip install ansible boto boto3 awscli

# Change to jenkins user
USER jenkins

# COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
# RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt