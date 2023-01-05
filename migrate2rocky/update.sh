#!/bin/bash

yum clean all
yum update -y

mv /etc/yum.repos.d /etc/yum.repos.d.bak
mkdir /etc/yum.repos.d/
cp ./CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo

chmod +x ./migrate2rocky.sh
./migrate2rocky.sh -r
