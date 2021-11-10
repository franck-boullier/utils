# Overview:

How to create a DEV machine from scratch.

# Pre-Requisite:

- You have access to a GCP project.
- You are allowed to create Compute instances in the project.
- You are allowed to access Remote Desktop with Google Chrome.

# The commands you need to run:

In the GCP Console

Make sure to replace `<project-name>` in the below code with the actual name of your GCP project.
We're assuming that you are creating the resource in the Singapore Region (`asia-southeast1`).

Select a name <machine-name> for your development machine

Set Project

```
gcloud config set project <project-name>
```

Download the code you'll need:

```
git clone https://github.com/franck-boullier/utils.git
```

and move to the folder where the script is.

```
cd ~/utils/installation
```

You can use the machine

```
https://github.com/franck-boullier/utils/blob/master/installation/tutorial-dev-machine.sh
```

Create a Fixed IP address for the machine
**Replace `<machine-name>` with the name of the machine before running the below code**

```
gcloud compute addresses create <machine-name>-ip \
 --project=<project-name> \
 --network-tier=STANDARD \
 --region=asia-southeast1
```

Put the IP address you've created in an environment variable.
**Replace `<machine-name>` with the name of the machine before running the below code**

```
IP_ADDRESS_DEV_MACHINE=$(gcloud compute addresses list \
 --filter="name:<machine-name>-ip AND region:asia-southeast1" \
 --format="value(address_range())"
 )
 ```

Make sure that the IP address is correctly captured

```
 echo $IP_ADDRESS_DEV_MACHINE
```

Create the instance

- Check the image for latest LTS version of Ubuntu. The below code uses `ubuntu-2004-focal-v20210927`.
- Make the machine a pre-emptible machine to optimise costs.
- Check the size of the disk. The below code creata a 30gb.
- Give a name to that machine: replace `<machine-name>` in the below code.
- Make sure that you are selecting the correct type of machine. The below code uses the [tutorial-dev-machine.sh](https://github.com/franck-boullier/utils/blob/master/installation/tutorial-dev-machine.sh).

```
gcloud compute instances create <machine-name> \
 --project=vocal-affinity-296007 \
 --zone=asia-southeast1-b \
 --machine-type=n1-standard-1 \
 --preemptible \
 --image=ubuntu-2004-focal-v20210927 \
 --image-project=ubuntu-os-cloud \
 --boot-disk-size=30GB \
 --boot-disk-type=pd-standard \
 --boot-disk-device-name=<machine-name> \
 --metadata-from-file startup-script=tutorial-dev-machine.sh \
 --network-tier=STANDARD \
 --address=$IP_ADDRESS_DEV_MACHINE \
 --subnet=default \
 --tags=http-server,https-server
 ```

 Go to the [Chrome Remote Desktop page to set up access to a new machine](https://remotedesktop.google.com/headless) and follow the instructions to get the code that you need to allow access to your remote VM.

Connect to the newly created machine with the Google SSH web connection interface from the Google console.

- Copy the "Access code to the remote" to your remote VM.
- Run that code
- Provide a six digits PIN where prompted.
- Go to [Google Chrome Remote Desktop](https://remotedesktop.google.com/access).
- Access the remote VM.