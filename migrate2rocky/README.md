# README
脚本将CentOS8.2升级到RockyLinux, 在百度云轻量应用服务器上验证通过

## 升级
```
# 执行升级
sh ./update.sh
# 重启
reboot
```
## 重启后重新配置
```
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
yum update -y
```
