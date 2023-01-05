#!/bin/bash

if [ -z $4 ]; then
	echo "sh install_frpc.sh <server_addr> <server_port> <remote_port> <token>"
	exit 1
fi

server_addr=$1
server_port=$2
remote_port=$3
token=$4

# frp
frp_version=0.46.0
if lscpu | grep x86_64; then
	frp_filename=frp_${frp_version}_linux_amd64
else
	frp_filename=frp_${frp_version}_linux_arm64
fi
frp_url="https://github.com/fatedier/frp/releases/download/v${frp_version}/${frp_filename}.tar.gz"
wget ${frp_url} -O /tmp/${frp_filename}.tar.gz
tar zxvf /tmp/${frp_filename}.tar.gz -C /tmp/
/bin/cp /tmp/${frp_filename}/frpc /usr/local/bin/frpc

# frpc.ini
mkdir -p /etc/frp
cat << EOF | tee /etc/frp/frpc.ini
[common]
server_addr = ${server_addr}
server_port = ${server_port}
authentication_method = token
token = ${token}

[ssh_${remote_port}]
type = tcp
local_ip = 127.0.0.1
local_port = 22
remote_port = ${remote_port}
EOF

# systemd
cat << EOF | tee /etc/systemd/system/frpc.service
[Unit]
Description = frp client
After = network.target syslog.target
Wants = network.target

[Service]
Type = simple
ExecStartPre=/bin/bash -c 'until host example.com; do sleep 1; done'
ExecStart = /usr/local/bin/frpc -c /etc/frp/frpc.ini

[Install]
WantedBy = multi-user.target
EOF


# start
systemctl daemon-reload
systemctl enable frpc
systemctl start frpc
systemctl status frpc
