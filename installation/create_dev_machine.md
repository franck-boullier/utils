# Overview:

How to create a DEV machine from scratch.

# Pre-Requisite:

- You have access to a GCP project.
- You are allowed to create Compute instances in the project.
- You are allowed to access Remote Desktop with Google Chrome.

# The commands you need to run:

In the GCP Console, open the Cloud Shell terminal.

Make sure to replace `<project-name>` in the below code with the actual name of your GCP project.
We're assuming that you are creating the resource in the Singapore Region (`asia-southeast1`).

# Variables You Need:

```bash
PROJECT=<id-of-your-gcp-project>
REGION=<the-region-where-resources-will-be-installed>
ZONE=<>
MACHINE_NAME=<a-name-for-your-machine>
NETWORK_TIER=<the-network-tier>
MACHINE_TYPE=n1-standard-1
IMAGE_PROJECT=ubuntu-os-cloud
OS_IMAGE=<most-recent-ubuntu-lts-image>
PATH_TO_INTALL_SCRIPT=./basic-dev-machine.sh
BOOT_DISK_SIZE=30GB
BOOT_DISK_TYPE=pd-standard
```

To find the list of available Ubuntu images, you can run

```bash
gcloud compute images list --filter ubuntu-os-cloud
```

**Replace `<each-variable>` as you see fit before running the below code**

Example:

```bash
MACHINE_NAME=my-dev-machine
REGION=asia-southeast1
ZONE=asia-southeast1-b
NETWORK_TIER=standard
MACHINE_TYPE=n1-standard-1
IMAGE_PROJECT=ubuntu-os-cloud
OS_IMAGE=ubuntu-2204-jammy-v20230616
PATH_TO_INSTAL_SCRIPT=./basic-dev-machine.sh
BOOT_DISK_SIZE=30GB
BOOT_DISK_TYPE=pd-standard
```

Select a name <machine-name> for your development machine

Set Project

```
gcloud config set project $PROJECT
```

Download the code you'll need:

```
git clone https://github.com/franck-boullier/utils.git fbo-utils
```

and move to the folder where the script is.

```
cd ~/fbo-utils/installation
```

You can use the machine

```
https://github.com/franck-boullier/utils/blob/master/installation/tutorial-dev-machine.sh
```

Create a Fixed IP address for the machine

```
gcloud compute addresses create $MACHINE_NAME-ip \
 --project=$PROJECT \
 --network-tier=$NETWORK_TIER \
 --region=$REGION
```

Put the IP address you've created in an environment variable.

```
IP_ADDRESS_DEV_MACHINE=$(gcloud compute addresses list \
 --filter="name:$MACHINE_NAME-ip AND region:$REGION" \
 --format="value(address)")
 ```

Make sure that the IP address is correctly captured

```
echo $IP_ADDRESS_DEV_MACHINE
```

Create the instance using the variables defined earlier:

```
gcloud compute instances create $MACHINE_NAME \
 --project=$PROJECT \
 --zone=$ZONE \
 --machine-type=$MACHINE_TYPE \
 --preemptible \
 --image=$OS_IMAGE \
 --image-project=$IMAGE_PROJECT \
 --boot-disk-size=$BOOT_DISK_SIZE \
 --boot-disk-type=$BOOT_DISK_TYPE \
 --boot-disk-device-name=$MACHINE_NAME \
 --metadata-from-file startup-script=$PATH_TO_INSTAL_SCRIPT \
 --network-tier=$NETWORK_TIER \
 --address=$IP_ADDRESS_DEV_MACHINE \
 --subnet=default \
 --tags=http-server,https-server
 ```

# Additional Configuration:

Make sure that the installation script has run correctly: 
check the status of a bash script that is currently running in the background you can open a terminal window on the machine and run the command

```bash
sudo journalctl -f -o cat
```

This displays the output of the script that's running in the background. Once done you can exit with `Crtl C`.

You need to make sure that the installation script is finished before doing the below steps.

## Configure Access Via Chrome Remote Access:

 Go to the [Chrome Remote Desktop page to set up access to a new machine](https://remotedesktop.google.com/headless) and follow the instructions to get the code that you need to allow access to your remote VM.

Connect to the newly created machine with the Google SSH web connection interface from the Google console.

- Copy the "Access code to the remote" to your remote VM.
- Run that code
- Provide a six digits PIN where prompted.
- Go to [Google Chrome Remote Desktop](https://remotedesktop.google.com/access).
- Access the remote VM.

## Disable Autoscreen Lock:

- Go to Application >> Settings >> Screensaver.
- Click on the `Lock Screen` tab.
- Untick the option `Enable Lock Screen`.

## Create a SSH Key:

- Go to the `.ssh` folder:

```bash
cd ~/.ssh
```

- Create a new ssh key

```bash
ssh-keygen -o -t rsa -C "your.address@email.com"
```

- Follow the on screen instructions (accept default).
- Best practice is to create a passphrase for the ssh key.

## Use an existing SSH key:

If you have an existing ssh key you can replace the content of the files:

- `id_rsa`: the PRIVATE key
- `id_rsa.pub`: The public key

With the correct value for your ssh key.

## Configure the Terminal to display the git branch:

- On the DEV machine, with VS Code, open the `~/.bashrc` file
- At the end of the file add the following line

```bash
(...)

# Display the git branch
git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

# Update the default PS1 variable
# original  `\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$`
# updated   `\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \$(git_branch)\$ "`
export PS1="\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \$(git_branch)\$ "
```

- Restart `.bashrc`

```bash
source ~/.bashrc
```

- Close the terminal.
- Re-opent the terminal.
- Go to a git enabled folder.
- Check that the branch is correctly displayed like

```bash
userName@machineName:~/Documents/github/vue.playground (master)$
```


