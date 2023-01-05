# README
脚本将CentOS8.2升级到RockyLinux, 在百度云轻量应用服务器上验证通过

`migrate2rocky.sh`修改自https://github.com/rocky-linux/rocky-tools/tree/main/migrate2rocky
去掉了校验逻辑`|| exit_message "Can't get package name for $provides."`, 不建议用于生产

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
