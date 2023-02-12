dd if=/dev/zero of=/swapfile bs=1M count=1024 status=progress
chmod 0600 /swapfile
mkswap /swapfile
swapon /swapfile
grep swapfile /etc/fstab || echo "/swapfile none swap defaults 0 0" >> /etc/fstab