#!/bin/bash

if [ -z $4 ]; then
	echo "sh install_frpc.sh <server_addr 代理服务器地址> <server_port 代理服务器frps端口> <remote_port 代理服务器监听端口> <local_port 客户端本地端口> <token> <:protocol> <:frp_version>"
	exit 1
fi

server_addr=$1
server_port=$2
remote_port=$3
local_port=$4
token=$5

if [ -z $6 ]; then
	protocol=SSH
else
	protocol=$6
fi

if [ -z $7 ]; then
	frp_version=0.46.1
else
	frp_version=$7
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
/bin/cp /tmp/${frp_filename}/frpc /usr/local/bin/frpc

# frpc.ini
mkdir -p /etc/frp
cat << EOF | tee /etc/frp/frpc.ini
[common]
server_addr = ${server_addr}
server_port = ${server_port}
authentication_method = token
token = ${token}

[$(hostname)_${protocol}_${remote_port}]
type = tcp
local_ip = 127.0.0.1
local_port = ${local_port}
remote_port = ${remote_port}
EOF

# systemd
cat << EOF | tee /etc/systemd/system/frpc.service
[Unit]
Description = frp client
After = network.target syslog.target
Wants = network.target
StartLimitIntervalSec=0

[Service]
Type = simple
Restart=always
RestartSec=30
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