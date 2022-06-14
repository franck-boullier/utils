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
 --project=<project-name> \
 --zone=asia-southeast1-b \
 --machine-type=n1-standard-1 \
 --preemptible \
 --image=ubuntu-2110-impish-v20220106 \
 --image-project=ubuntu-os-cloud \
 --boot-disk-size=30GB \
 --boot-disk-type=pd-standard \
 --boot-disk-device-name=<machine-name> \
 --metadata-from-file startup-script=<install-script> \
 --network-tier=STANDARD \
 --address=$IP_ADDRESS_DEV_MACHINE \
 --subnet=default \
 --tags=http-server,https-server
 ```

# Configure Chrome Remote Desktop: 

## SSH in to the DEV Machine:

In the Google Cloud Shell:

```bash
PROJECT=add-your-project-name-here
ZONE=add-the-zone-where-the-machine-is-here
MACHINE_NAME=add-the-name-of-the-machine-here
gcloud compute ssh ${MACHINE_NAME} --project=${PROJECT} --zone=${ZONE}
```

## Get the Chrome Remote Desktop Configuration Page:
 
- Go to the [Chrome Remote Desktop page to set up access to a new machine](https://remotedesktop.google.com/headless) and follow the instructions to get the code that you need to allow access to your remote VM.

Connect to the newly created machine with the Google SSH web connection interface from the Google console.

- Copy the "Access code to the remote" to your remote VM.
- Run that code
- Provide a six digits PIN where prompted.
- Go to [Google Chrome Remote Desktop](https://remotedesktop.google.com/access).
- Access the remote VM.

# Additional Configuration:

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
