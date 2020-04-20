# WireGuard installer

**This project is a bash script that aims to setup a [WireGuard]
(https://www.wireguard.com/) VPN on a Linux server, 
Do not ask any question.
Just install the Wireguard VPN server and give me the client config **

The script supports both IPv4 only and no iptables script here. iptables script is in seperate file.

![Image Sample Output](https://github.com/abdsmd/wireguard-install/raw/master/download.png)


## Requirements

Supported distributions:

- Ubuntu
- Debian
- Fedora
- CentOS 7
- Arch Linux


## Usage

Download and execute the script. Answer the questions asked by the script and it will take care of the rest.

```bash
curl -O https://raw.githubusercontent.com/abdsmd/wireguard-install/master/wireguard-install.sh
chmod +x wireguard-install.sh
./wireguard-install.sh
```

It will install WireGuard (kernel module and tools) on the server, configure it, create a systemd service and a client configuration file.

To generate more client files, run the following:

```sh
./wireguard-install.sh add_client
```

Make sure you choose different IPs for you clients.

