

apt-get update -y

apt-get install vim -y
apt-get install net-tools -y
apt-get install tree -y
apt-get --fix-broken install -y
# apt-get install trace-routers -y



echo "安装openssh-server..."

# 安装 openssh
apt-get install openssh-server -y
echo "设置root密码"
# 设置root密码
sudo passwd root

echo "配置"
vim /etc/ssh/sshd_config
echo "找到 PermitRootLogin prohibit-password , 改为 PermitRootLogin yes (可将原值注释掉)"
echo "
# 自动启用
systemctl enable ssh.service
# 重启ssh
service ssh restart
"

# 防火墙设置
systemctl status ssh
ufw allow ssh
systemctl enable --now ssh



# 自动补全的问题
apt-get install -y bash-completion
ls -l /bin/sh
dpkg-reconfigure dash
cd /usr/share/bash-completion
chmod +x ./bash_completion
./bash_completion
source /etc/bash_completion


# sudo systemctl daemon-reload		#重启daemon进程
# sudo systemctl restart docker		#重启docker