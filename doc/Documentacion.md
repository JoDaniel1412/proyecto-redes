Tecnológico de Costa Rica.

Escuela de Ingeniería en Computación.

IC: 7602-Redes - 2 Semestre 2022.

2018086509 - Jocxan Sandi Batista.

José Daniel Acuña.

---

## Índice

- Infraestructura en Terraform.
- Load balancer 
- DNS
- VPN
- Web proxy cache
- Referencias


## Infraestructura en Terraform.

### VM del VPN

Para automatizar la instalación del VPN  se utilizo un ***provisioner*** que se conecta a la máquina virtual y ejecuta una serie de comandos.
Los cuales son:

1. Dar permisos a la carpeta en la que se va a trabajar.
2. Ir a la carpeta de trabajo.
3. Descargar un archivo de los comandos que hacen toda la instalación del VPN y Web proxy cache. 
4. Cambia el string **IP_PUBLIC_MAQUINE_VIRTUAL** por la IP publica de la máquina.
4. Cambia el string **IP_PUBLIC_MAQUINE_VIRTUAL:3128** por la IP publica de la máquina.
5. Le da permisos al archivo para poder ejecutarse.
6. Ejecuta los comandos dentro del archivo. 

``` 

provisioner "remote-exec" {
    inline = count.index < 2 ? [
      "chmod +x /home/azureuser/",
      "cd /home/azureuser/",
      "wget https://raw.githubusercontent.com/JocxanS7/Redes/master/comandos.sh",
      "sed -i 's/\"IP_PUBLIC_MAQUINE_VIRTUAL\"/\"${azurerm_public_ip.vm-pip.ip_address}\"/g' comandos.sh",
      "sed -i 's/\"IP_PUBLIC_MAQUINE_VIRTUAL:3128\"/\"${azurerm_public_ip.vm-pip.ip_address}:3128\"/g' comandos.sh",
      "sudo chmod +x /home/azureuser/comandos.sh",
      "bash /home/azureuser/comandos.sh"
      

      
    ] : null
    connection { 
      type        = count.index < 2 ? "ssh" : null
      host        = count.index < 2 ? "${azurerm_public_ip.vm-pip.ip_address}" : null
      user        = count.index < 2 ? var.vm_cred.user : null
      private_key = count.index < 2 ? file("./ssh/id_rsa") : null
    }

```


## VPN

Se utilizo el cookbook 'openvpn', '~> 7.0.13'.

Se utilizo la siguiente configuración, además se encuentra el archivo que automatiza la instalación en ./vpn/comandos.sh:


```
"openvpn": {
        "gateway": "IP_PUBLIC_MAQUINE_VIRTUAL",
        "push_options": { "dhcp-option":  [ "DNS 8.8.8.8" ], "redirect-gateway": ["autolocal"] },
        "config": {
            "proto": "tcp",
            "port": "443"},
        "key": {"ca_expire": 3000}

    }
```

Además se creo un usuario para poder usar el vpn. 

## Web proxy cache 

No se puede probar porque se levanta el servicio en el puerto TCP6 3128.

Se utilizo el cookbook 'squid', '~> 4.4.5'.

Se utilizo la siguiente configuración además se encuentra el archivo que automatiza la instalación en ./vpn/comandos.sh:

```
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

```

## Referencias

Clase del Profesor Nereo Campos para realizar el VPN. 
https://supermarket.chef.io/cookbooks/openvpn
https://supermarket.chef.io/cookbooks/squid
https://superuser.com/questions/994728/force-squid-to-connect-to-sites-over-ipv4-rather-than-ipv6
https://tecadmin.net/setup-squid-proxy-server-on-ubuntu/
https://developer.hashicorp.com/terraform/language/resources/provisioners/syntax
https://developer.hashicorp.com/terraform/language/resources/provisioners/connection
https://developer.hashicorp.com/terraform/language/resources/provisioners/remote-exec