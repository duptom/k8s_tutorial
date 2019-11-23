iptables -I INPUT -p tcp --dport 6443 --syn -j ACCEPT
iptables -I INPUT -p tcp --match multiport --dport 2379:2380 --syn -j ACCEPT
iptables -I INPUT -p tcp --match multiport --dport 10250:10252 --syn -j ACCEPT

sudo ufw disable
service iptables save
