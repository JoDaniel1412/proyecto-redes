# ======== Comandos VPN y Squid ======== 

# Install Chef Client

wget https://packages.chef.io/files/stable/chef-workstation/21.10.640/ubuntu/20.04/chef-workstation_21.10.640-1_amd64.deb
yes | sudo dpkg -i chef-workstation_21.10.640-1_amd64.deb
chef generate repo chef-repo --chef-license accept
cd chef-repo

# Download Cookbooks from Chef Supermarket

cd cookbooks
knife supermarket download openvpn 7.0.13 -y
tar -xvvzf openvpn-7.0.13.tar.gz
knife supermarket download yum-epel 5.0.0 -y
tar -xvvzf yum-epel-5.0.0.tar.gz
knife supermarket download squid 4.4.5 -y
tar -xvvzf squid-4.4.5.tar.gz

# Create the Data Bags needed for the Cookbooks

cd ..
cd data_bags
mkdir users
cd users
echo '{
    "id": "jocxan",
    "key_country": "US",
    "key_province": "CA",
    "key_city": "San Francisco",
    "key_email": "jocxansandi@gmail.com",
    "key_size": 2048,
    "key_org": "TEC",
    "key_org_unit": "TEC- Compu"
}'> jocxan.json
cd ..
mkdir squid_acls
cd squid_acls
echo '{
  "id": "squid_acls",
  "acl_rules": [
    {
      "name": "acl_ipv4",
      "type": "src",
      "acl": "10.0.0.0/8 172.16.0.0/12 192.168.0.0/16",
      "comment": "Allow only IPv4 traffic"
    }
  ]
}' > squid_acls.json
cd ..
mkdir squid_hosts
cd squid_hosts
echo '{
  "id": "squid_hosts",
  "host_rules": [
    {
      "name": "ipv4_hosts",
      "type": "src",
      "hosts": "10.0.0.0/8 172.16.0.0/12 192.168.0.0/16",
      "comment": "Allow only IPv4 hosts"
    }
  ]
}' > squid_hosts.json
cd ..
mkdir squid_urls
cd squid_urls
echo '{
    "id": "squid_urls",
    "url_rules": [
      {
        "name": "all_urls",
        "type": "url_regex",
        "url_regex": ".*",
        "comment": "Allow all URLs"
      }
    ]
  }' > squid_urls.json

# Creates a node.json

cd ..
cd ..
echo '{

    "run_list": [ "recipe[openvpn::enable_ip_forwarding]", "recipe[openvpn::server]", "recipe[openvpn::easy_rsa]", "recipe[openvpn::users]" , "recipe[squid]"  ] ,
    "openvpn": {
        "gateway": "IP_PUBLIC_MAQUINE_VIRTUAL",
        "push_options": { "dhcp-option":  [ "DNS 8.8.8.8" ], "redirect-gateway": ["autolocal"] },
        "config": {
            "proto": "tcp",
            "port": "443"},
        "key": {"ca_expire": 3000}

    },
    "squid": {
        "config":{
            "dns_v4_first": true,
            "dns_nameservers": ["8.8.8.8", "8.8.4.4"],
            "ipv4": true,
            "ipv6": false,
            "ipv4_only": true,
            "port": "0.0.0.0:3128",
            "http_port": "0.0.0.0:3128",
            "http_access_deny_all": false,
            "localnets" : ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"],
            "expire_policy": {
                "max_age": "3600"
            },
            "access_log": "/var/log/squid/access.log",
            "logformat": "squid",
            "custom_log_format": "%{%Y-%m-%dT%H:%M:%S}tl %6tr %>a %Ss/%03>Hs %<st %rm %ru %un %Sh/%<a %mt",
            "tcp_outgoing_address": "IP_PUBLIC_MAQUINE_VIRTUAL"
        }
    }

}' > node.json

# Creates a solo.rb

cd chef-repo
echo 'current_dir = File.expand_path(File.dirname(__FILE__))
file_cahe_path "#{current_dir}"
cookbook_path  "#{current_dir}/cookbooks"
role_path "#{current_dir}/roles"
data_bag_path "#{current_dir}/data_bags" ' > solo.rb

# Run Chef Solo

sudo chef-solo -c solo.rb -j node.json --chef-license accept
sudo iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE


# ======== Comandos Proxy Reverso ======== 

# Install Chef Client

wget https://packages.chef.io/files/stable/chef-workstation/21.10.640/ubuntu/20.04/chef-workstation_21.10.640-1_amd64.deb
yes | sudo dpkg -i chef-workstation_21.10.640-1_amd64.deb
chef generate repo chef-repo --chef-license accept

# Download Cookbooks from Chef Supermarket

cd chef-repo
cd cookbooks

knife supermarket download nginx
tar -xvvzf nginx-12.2.0.tar.gz 

# Creates a Default Recipe to use the Cookbook Resources

cd nginx

mkdir recipes
cd recipes

echo 'nginx_install "default"
nginx_config "default"

nginx_service "default" do
  action [:start, :enable]
end

nginx_site "default" do
  template "site-template.erb"
end
' > default.rb

# Creates a node.json

cd ..
cd ..
cd ..

echo '{
  "run_list": [
    "recipe[nginx::default]"
  ],
  "nginx": {
    "default_site_enabled": false,
    "sites": {
      "server1": {
        "server_name": "server1",
        "document_root": "/var/www/server1"
      },
      "server2": {
        "server_name": "server2",
        "document_root": "/var/www/server2"
      }
    },
    "proxies": {
      "server1": {
        "url": "http://<ip_de_server1>:80"
      },
      "server2": {
        "url": "http://<ip_de_server2>:80"
      }
    }
  }
}' > node.json

# Creates a solo.rb

echo 'current_dir = File.expand_path(File.dirname(__FILE__))
file_cahe_path "#{current_dir}"
cookbook_path  "#{current_dir}/cookbooks"
role_path "#{current_dir}/roles"
data_bag_path "#{current_dir}/data_bags" ' > solo.rb

# Run Chef Solo

sudo chef-solo -c solo.rb -j node.json --chef-license accept