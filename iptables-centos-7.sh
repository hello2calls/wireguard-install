setenforce 0

cat <<EOF >/etc/sysconfig/selinux
SELINUX=disable
SELINUXTYPE=targeted
EOF

yum update -y
yum install nano zip unzip yum wget curl  dos2unix net-tools -y
yum install epel-release -y
yum update -y

cat <<EOF >/etc/sysctl.conf 
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0
kernel.exec-shield = 1
kernel.randomize_va_space = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 2048
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 5
net.ipv4.conf.all.log_martians = 0
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
# Ignore ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.all.proxy_arp = 1
net.ipv4.ip_forward = 1
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
net.ipv6.conf.eth0.disable_ipv6 = 1
EOF

echo 1 > /proc/sys/net/ipv4/ip_forward
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
echo 1 > /proc/sys/net/ipv6/conf/default/disable_ipv6
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1

sysctl -p

systemctl stop firewalld && systemctl mask firewalld && systemctl disable firewalld

yum  -y install iptables-services
systemctl restart iptables

# IPTables Masquarading for Internet
iname=$(ip addr show | awk '/inet.*brd/{print $NF; exit}')
echo $iname
iptables -F
iptables -t nat -F
iptables -I FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
iptables -A OUTPUT -p tcp --dport 25 -j REJECT
iptables -t nat -A POSTROUTING -o $iname -j MASQUERADE
iptables-save > /etc/sysconfig/iptables

# for OpenVZ make sure venet0, not venet0:0

systemctl restart iptables
systemctl enable iptables && systemctl enable iptables.service

iptables -L
iptables -t nat -L

#####################################
#  Disable Broadcast Message ########
#####################################

sed -i "/ForwardToWall/c\ForwardToWall=no" /etc/systemd/journald.conf
systemctl restart systemd-journald
sed -e '/emerg/ s/^#*/#/' -i /etc/rsyslog.conf
systemctl restart rsyslog


