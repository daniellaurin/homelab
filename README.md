# My Home Lab Setup Guide

## Introduction
This guide outlines the setup and configuration of my personal home lab, which includes a Debian server, various services, and some troubleshooting steps I've encountered along the way.

## Server Specifications
- **Name:** Daniel
- **Server Name:** dell-precision-3620
- **IP Address:** 192.168.4.2

## Home Lab Software Reference Table

| Program | Description | Website/Repository |
|---------|-------------|---------------------|
| CasaOS | Open-source home cloud system | [https://casaos.io/](https://casaos.io/) |
| Cockpit | Web-based server manager | [https://cockpit-project.org/](https://cockpit-project.org/) |
| NextCloud | Self-hosted cloud storage | [https://nextcloud.com/](https://nextcloud.com/) |
| Docker | Containerization platform | [https://www.docker.com/](https://www.docker.com/) |
| Timeshift | System backup tool | [https://github.com/teejee2008/timeshift](https://github.com/teejee2008/timeshift) |
| Netplan | Network configuration tool | [https://netplan.io/](https://netplan.io/) |
| SSH | Secure Shell for remote access | [https://www.ssh.com/academy/ssh](https://www.ssh.com/academy/ssh) |
| Fish Shell | User-friendly command line shell | [https://fishshell.com/](https://fishshell.com/) |
| Tmux | Terminal multiplexer | [https://github.com/tmux/tmux](https://github.com/tmux/tmux) |
| NVIDIA Drivers | Graphics drivers | [https://www.nvidia.com/en-us/drivers/unix/](https://www.nvidia.com/en-us/drivers/unix/) |
| APT | Package management system | [https://wiki.debian.org/Apt](https://wiki.debian.org/Apt) |
| UFW | Uncomplicated Firewall | [https://wiki.ubuntu.com/UncomplicatedFirewall](https://wiki.ubuntu.com/UncomplicatedFirewall) |
| Vim | Text editor | [https://www.vim.org/](https://www.vim.org/) |

## Initial Setup

### 1. CasaOS Installation
CasaOS is a simple, easy-to-use, and open-source home cloud system.

```bash
curl -fsSL https://get.casaos.io | sudo bash
```

Access CasaOS at `http://192.168.4.2:81`

### 2. SSH Access
To access the server via SSH:

```bash
kitten ssh daniel-laurin-uba@192.168.4.2
```

## Service Installations

### 1. Cockpit (Web-based server manager)
Install and set up Cockpit for easy server management:

```bash
sudo apt update
sudo apt install cockpit -y
sudo systemctl start cockpit
sudo systemctl status cockpit
ss -tunlp | grep 9090
sudo ufw allow 9090/tcp
sudo apt install cockpit-machines -y
```

Access Cockpit at `https://192.168.4.2:9090`

### 2. NextCloud (Self-hosted cloud storage)
NextCloud was set up, but the guide mentions it's not working. Troubleshooting may be required.

### 3. Docker
Install Docker for containerized applications:

```bash
sudo apt install apt-transport-https ca-certificates curl software-properties-common
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-cache policy docker-ce
sudo apt install docker-ce
sudo systemctl status docker
sudo usermod -aG docker ${USER}
```

To run and access Docker containers:

```bash
docker ps 
docker exec -it <container-name-or-id> /bin/bash
```

### 4. Timeshift (System backup tool)
Install and create a backup using Timeshift:

```bash
sudo apt install timeshift
sudo timeshift --create --comments "first backup" --tags W
```

## Network Configuration

### Static IP Address Setup
To set a static IP address:

1. Edit the Netplan configuration file:

```bash
sudo vim /etc/netplan/00-installer-config.yaml
```

2. Add the following configuration:

```yaml
network:
  ethernets:
    enp9s31f6:
      dhcp4: no
      addresses:
        - 192.168.4.2/24
      routes:
        - to: default
          via: 192.168.4.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
  version: 2
```

3. Apply the changes:

```bash
sudo netplan apply
sudo chmod 600 /etc/netplan/00-installer-config.yaml
```

## Security Measures

### Disable SSH Root Login
To enhance security, disable SSH root login:

1. Edit the SSH configuration file:

```bash
sudo vim /etc/ssh/sshd_config
```

2. Set the following line:

```
PermitRootLogin no
```

3. Restart the SSH service:

```bash
sudo systemctl restart ssh
```

### SSH Key-based Authentication
Set up SSH key-based authentication for more secure access:

```bash
ssh-keygen -t rsa -b 4096 
ssh-copy-id dlaurin-deb@192.168.4.2
```

Then, edit the SSH configuration to disable password authentication:

```bash
sudo vim /etc/ssh/sshd_config
```

Uncomment or add these lines:

```
PasswordAuthentication no
PubkeyAuthentication yes
```

Restart the SSH service:

```bash
sudo systemctl restart ssh
```

## Shell Configuration

### Fish Shell
To set up Fish as the default shell with some custom configurations:

1. Create or edit the Fish configuration file:

```bash
vim ~/.config/fish/config.fish
```

2. Add the following content:

```fish
if status is-interactive
    # Commands to run in interactive sessions can go here
    set -U fish_greeting ""
end

if status is-interactive
    and not set -q TMUX
    exec tmux
end

# Define a custom function to accept autosuggestions
function accept_autosuggestion
    # This command replaces the current command line with the autosuggested command
    commandline -f repaint
end

# Bind Ctrl+O to the custom function
bind \cO accept-autosuggestion
```

3. Source the configuration:

```bash
source ~/.config/fish/config.fish
```

### Tmux Configuration
To set up Tmux with Fish as the default shell:

1. Create a Tmux configuration file:

```bash
touch ~/.tmux.conf
```

2. Add the following line to the file:

```
set -g default-shell /usr/bin/fish
```

## Troubleshooting

### NVIDIA Driver Installation
If you encounter issues with NVIDIA drivers:

1. Check for conflicting drivers:

```bash
lsmod | grep nouveau
lspci -nn | egrep -i "3d|display|vga"
```

2. Install NVIDIA proprietary drivers:

```bash
sudo apt update
sudo apt install nvidia-legacy-390xx-driver firmware-misc-nonfree
sudo reboot
```

3. Verify installation:

```bash
nvidia-smi
```

### Fixing Broken Packages
If you encounter broken packages:

```bash
sudo dpkg --configure -a
sudo apt install -f
sudo apt remove --purge [package_name]
sudo apt autoremove
sudo apt clean
```

## Conclusion
This guide covers the basic setup and configuration of my home lab. It includes server setup, service installations, network configuration, security measures, and some troubleshooting steps. As with any home lab, continuous learning and adjustment are part of the process. Feel free to modify and expand upon this setup to suit your needs.