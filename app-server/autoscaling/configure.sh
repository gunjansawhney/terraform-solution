#! /bin/bash
exec >/tmp/logfile.txt 2>&1
yum update -y
yum install lvm2* -y
pvcreate /dev/xvdb /dev/xvdc
vgcreate vgebs /dev/xvdb /dev/xvdc
lvcreate -n lvebs -L 3.99G vgebs
mkfs.xfs /dev/vgebs/lvebs
mkdir /logdevices
mount /dev/vgebs/lvebs /logdevices
echo "/dev/mapper/vgebs-lvebs /logdevices xfs defaults 0 0" >> /etc/fstab

yum install httpd -y
sudo systemctl start httpd
sudo systemctl enable httpd
echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html
ln -s /var/log/httpd /logdevices/apacheLogs
