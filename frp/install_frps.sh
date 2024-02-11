#!/bin/bash

if [ -z $2 ]; then
	echo "sh install_frps.sh <bind_port> <token> <:frp_version>"
	exit 1
fi

bind_port=$1
token=$2
if [ -z $3 ]; then
	frp_version=0.54.0
else
	frp_version=$3
fi

# frp
if lscpu | grep x86_64; then
	frp_filename=frp_${frp_version}_linux_amd64
else
	frp_filename=frp_${frp_version}_linux_arm64
fi

frp_url="https://github.com/fatedier/frp/releases/download/v${frp_version}/${frp_filename}.tar.gz"
wget ${frp_url} -O /tmp/${frp_filename}.tar.gz
tar zxvf /tmp/${frp_filename}.tar.gz -C /tmp/
/bin/cp /tmp/${frp_filename}/frps /usr/local/bin/frps

# frps.ini
mkdir -p /etc/frp
cat << EOF | tee /etc/frp/frps.toml
bindAddr = "0.0.0.0"
bindPort = ${bind_port}
kcpBindPort = ${bind_port}
transport.maxPoolCount = 100
enablePrometheus = true
log.to = "/var/log/frps.log"
# trace, debug, info, warn, error
log.level = "info"
log.maxDays = 3
log.disablePrintColor = false
auth.method = "token"
auth.token = ${token}
# ssh tunnel gateway
sshTunnelGateway.bindPort = 7722
sshTunnelGateway.privateKeyFile = "/home/frp-user/.ssh/id_rsa"
sshTunnelGateway.autoGenPrivateKeyPath = ""
sshTunnelGateway.authorizedKeysFile = "/home/frp-user/.ssh/authorized_keys"
EOF

# systemd
cat << EOF | tee /etc/systemd/system/frps.service
[Unit]
Description = frp server
After = network.target syslog.target
Wants = network.target

[Service]
Type = simple
ExecStart = /usr/local/bin/frps -c /etc/frp/frps.toml

[Install]
WantedBy = multi-user.target
EOF


# start
systemctl daemon-reload
systemctl enable frps --now
systemctl status frps
