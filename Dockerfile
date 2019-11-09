FROM jenkins/jenkins:lts
MAINTAINER Aditya Avanth <avant.aditya@gmail.com>

#suppress apt installation warnings
ENV DEBIAN_FRONTEND=noninteractive

#change to root user to perform installations
USER root

#Set the docker group id
#Use 497 as it is the default group id used in AWS linux ec2 instances
ARG DOCKER_GID=497

#create docker group with this group id
RUN groupadd -g ${DOCKER_GID:-497} docker

#Use the below docker engine and docker compose versions
ARG DOCKER_ENGINE=1.10.2
ARG DOCKER_COMPOSE=1.6.2

#Install base packages
RUN apt-get update &&\
    apt-get install lsb-release software-properties-common apt-transport-https curl python-dev python-setuptools gcc make libssl-dev -y &&\
    easy_install pip


#Install docker engine mine
RUN curl -fsSL https://apt.dockerproject.org/gpg | apt-key add - &&\
    apt-add-repository "deb https://apt.dockerproject.org/repo debian-stretch main" &&\
    apt-get update &&\
    apt-cache policy docker-engine &&\
    apt-get install -y docker-engine=1.13.1-0~debian-stretch &&\
    usermod -aG docker jenkins &&\
    usermod -aG users jenkins &&\
    usermod -aG root jenkins


#Install docker compose using pip
RUN pip install docker-compose==${DOCKER_COMPOSE:-1.6.2} &&\
    pip install ansible boto boto3


#Change to jenkins user
USER jenkins

#Add jenkins plugins
COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt
