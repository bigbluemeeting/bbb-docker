#!/bin/bash
#docker stop bbb && docker rm bbb

CID=$(sudo docker run -d -e HOSTIP=test.bigbluemeeting.com --name bbb --network="host" --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro  bigbluemeeting/bbb-docker:latest)
CIP=$(sudo docker inspect --format='{{.NetworkSettings.IPAddress}}' $CID)

docker cp fix-ips.sh $CID:/root && docker exec -i $CID chmod +x /root/fix-ips.sh && docker exec -i $CID /root/fix-ips.sh

#sudo iptables -A DOCKER -t nat -p udp -m udp ! -i docker0 --dport 16384-32768 -j DNAT --to-destination $CIP:16384-32768
#sudo iptables -A DOCKER -p udp -m udp -d $CIP/32 ! -i docker0 -o docker0 --dport 16384:32768 -j ACCEPT
#sudo iptables -A POSTROUTING -t nat -p udp -m udp -s $CIP/32 -d $CIP/32 --dport 16384:32768 -j MASQUERADE
