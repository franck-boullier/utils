# Overview:

How to create a DEV machine from scratch.

# Pre-Requisite:

- You have access to a [GCP project](https://console.cloud.google.com).
- You are allowed to create Compute instances in the project.
- You are allowed to access Remote Desktop with Google Chrome.

# Step-by-step:

See all the details in this article: [How I’ve slashed the cost of my DEV environments by 90%](https://itnext.io/how-ive-slashed-the-cost-of-my-dev-environments-by-90-9c1082ad1baf?source=your_stories_page---------------------------).

# Additional Tips And Tricks:

To find the list of available Ubuntu images, you can run

```bash
gcloud compute images list --filter ubuntu-os-cloud
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

### Use an existing SSH key:

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


