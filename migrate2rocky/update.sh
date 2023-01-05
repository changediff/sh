#!/bin/bash

## pre migrate
yum clean all
yum update -y

mv /etc/yum.repos.d /etc/yum.repos.d.bak
mkdir /etc/yum.repos.d/
cp ./CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo

## do migrate
chmod +x ./migrate2rocky.sh
./migrate2rocky.sh -r

## use ustc mirror
sed -e 's|^mirrorlist=|#mirrorlist=|g' \
    -e 's|^#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=https://mirrors.ustc.edu.cn/rocky|g' \
    -i.bak \
    /etc/yum.repos.d/Rocky-AppStream.repo \
    /etc/yum.repos.d/Rocky-BaseOS.repo \
    /etc/yum.repos.d/Rocky-Extras.repo \
    /etc/yum.repos.d/Rocky-PowerTools.repo

## do update
yum update -y
