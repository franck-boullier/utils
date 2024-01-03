#!/bin/bash

# Set the Environment variables
PROJECT=<name-of-your-gcp-project>
MACHINE_NAME=<name-of-your-dev-machine>
REGION=asia-southeast1
ZONE=asia-southeast1-a
STARTUP_SCRIPT=startup.sh
MACHINE_TYPE=n1-standard-2
UBUNTU_IMAGE=ubuntu-2204-jammy-v20230919
IMAGE_PROJECT=ubuntu-os-cloud
DISK_SIZE=200GB

###################################################
#
# We have all the variables we need. Let's build!
#
###################################################

# Set the project
gcloud config set project $PROJECT

# Create IP address
gcloud compute addresses create ${MACHINE_NAME}-ip \
 --project=${PROJECT} \
 --network-tier=STANDARD \
 --region=${REGION}

# Store IP Address in a variable
IP_ADDRESS_DEV_MACHINE=$(gcloud compute addresses list \
 --filter="name:${MACHINE_NAME}-ip AND region:${REGION}" \
 --format="value(address_range())"
 )

# Check that the IP Address was created
echo $IP_ADDRESS_DEV_MACHINE

# Create the Instance
gcloud compute instances create ${MACHINE_NAME} \
 --project=${PROJECT} \
 --zone=${ZONE} \
 --machine-type=${MACHINE_TYPE} \
 --preemptible \
 --image=${UBUNTU_IMAGE} \
 --image-project=${IMAGE_PROJECT} \
 --boot-disk-size=${DISK_SIZE} \
 --boot-disk-type=pd-standard \
 --boot-disk-device-name=${MACHINE_NAME} \
 --metadata-from-file startup-script=${STARTUP_SCRIPT} \
 --network-tier=STANDARD \
 --address=$IP_ADDRESS_DEV_MACHINE \
 --subnet=default \
 --tags=http-server,https-server

