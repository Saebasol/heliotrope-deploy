# CloudFlare email
# > user@domain.tld
cf_email=
# CloudFlare global API key
# > Grab it from CloudFlare > Profile > API keys
cf_key=
# Home directory
home_dir=

# Set iptables rules
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --sport 22 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dports 80,443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -m multiport --dports 80,443 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A INPUT -j LOG
iptables -A FORWARD -j LOG
ip6tables -A INPUT -j LOG
ip6tables -A FORWARD -j LOG
netfilter-persistent save


curl https://get.acme.sh | sh -s email=$cf_email && \
  $home_dir/heliotrope-deploy/.acme.sh/acme.sh --issue --dns dns_cf -d api.saebasol.org

echo "export CF_Key=\"$cf_key\"" >> $home_dir/heliotrope-deploy/.acme.sh/account.conf
echo "export CF_Email=\"$cf_email\"" >> $home_dir/heliotrope-deploy/.acme.sh/account.conf

ln -s $home_dir/heliotrope-deploy/.acme.sh $home_dir/heliotrope-deploy/docker/certs

$_runas bash<<EOF
  docker network create -d bridge saebasol
  cd $home_dir/heliotrope-deploy/docker/database
  docker-compose up -d
  cd $home_dir/heliotrope-deploy/docker/mongo
  docker-compose up -d
  docker exec -d mongo `mongo -u heliotrope -p heliotrope --eval "db.getSiblingDB('hitomi').createCollection('info')"`
  docker exec -d mongo `mongo -u heliotrope -p heliotrope --eval "db.getSiblingDB('hitomi').getCollection('info').createIndex({'title':'text'}, {'language_override': 'korean'})"`
  cd $home_dir/heliotrope-deploy/docker/gateway
  docker-compose up -d
  cd $home_dir/heliotrope-deploy/docker/heliotrope
  docker-compose up -d
  docker ps
EOF