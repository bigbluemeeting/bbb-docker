FROM ubuntu:16.04
MAINTAINER sami.khan@bigbluemeeting.com

ENV DEBIAN_FRONTEND noninteractive
# RUN echo 'Acquire::http::Proxy "http://192.168.2.69:3142";'  > /etc/apt/apt.conf.d/01proxy
RUN apt-get update && apt-get dselect-upgrade -y
ADD bbb-install/bbb-install.sh /root/bbb-install.sh
RUN chmod +x /root/bbb-install.sh
ENV HOSTIP test.bigbluemeeting.com
ENV MAIL contact@bigbluemeeting.com
RUN /root/bbb-install.sh -s ${hostip} -e ${mail} -g
EXPOSE 80 443
EXPOSE 16384-32768/udp

VOLUME ["/var/freeswitch/meetings", "/usr/share/red5/webapps/video/streams", "/var/kurento/recordings", "/var/usr/share/red5/webapps/screenshare/streams", "/var/kurento/screenshare", "/var/bigbluebutton"]


# -- Finish startup
CMD /root/bbb-install.sh -s $HOSTIP -e $MAIL -g
