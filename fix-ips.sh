#!/bin/bash
local_ip="$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' | grep -v 172)"
sed -i -e "s/172.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/$local_ip/g" /usr/local/bigbluebutton/bbb-webrtc-sfu/config/default.yml
sed -i -e "s/172.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/$local_ip/g" /opt/freeswitch/etc/freeswitch/vars.xml
sed -i -e "s/172.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/$local_ip/g" /etc/bigbluebutton/nginx/sip.nginx
sed -i -e "s/172.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/$local_ip/g" /usr/share/red5/webapps/sip/WEB-INF/bigbluebutton-sip.properties
sed -i -e "s/0\.0\.0\.0/127\.0\.0\.1/g" /opt/freeswitch/etc/freeswitch/autoload_configs/event_socket.conf.xml
sed -i -e "s/172.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/$HOSTIP/g" /etc/nginx/sites-available/bigbluebutton
mkdir -p /etc/nginx/ssl
if [[ ! -f "/etc/nginx/ssl/dhp-4096.pem" ]]
then
    openssl dhparam -out /etc/nginx/ssl/dhp-4096.pem 4096
fi
systemctl restart nginx
ssl_cert_count="$(ls -1q /etc/letsencrypt/live/$HOSTIP/ | wc -l)"
if (( ! ssl_cert_count > 0 )); then
    certbot --webroot -w /var/www/bigbluebutton-default/ -d $HOSTIP -m $MAIL certonly
fi
read -r -d '' ssl <<-_EOT_
  listen 80;
  listen 443 ssl;
  listen [::]:443 ssl;
  ssl_certificate \/etc\/letsencrypt\/live\/${HOSTIP})\/fullchain.pem;
  ssl_certificate_key \/etc\/letsencrypt\/live\/${HOSTIP}\/privkey.pem;
  ssl_session_cache shared:SSL:10m;
  ssl_session_timeout 10m;
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
  ssl_ciphers "ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:ECDH+3DES:DH+3DES:RSA+AESGCM:RSA+AES:RSA+3DES:!aNULL:!MD5:!DSS:!AES256";
  ssl_prefer_server_ciphers on;
  ssl_dhparam \/etc\/nginx\/ssl\/dhp-4096.pem;
_EOT_
sed -i -e 's/listen   80;/$ssl/g' /etc/nginx/sites-available/bigbluebutton
systemctl restart nginx

read -r -d '' cron <<_EOF
30 2 * * 1 /usr/bin/certbot renew >> /var/log/le-renew.log
35 2 * * 1 /bin/systemctl reload nginx
_EOF


