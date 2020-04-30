FROM ubuntu:16.04
MAINTAINER sami.khan@bigbluemeeting.com

ENV DEBIAN_FRONTEND noninteractive

RUN sed -i 's/# deb/deb/g' /etc/apt/sources.list
RUN echo 'Acquire::http::Proxy "http://176.9.2.153:3142";'  > /etc/apt/apt.conf.d/01proxy
RUN echo 'Acquire::HTTPS::Proxy "false";' >> /etc/apt/apt.conf.d/01proxy



RUN apt-get update \
    && apt-get install -y systemd systemd-sysv software-properties-common\
    && apt-get clean \
    && add-apt-repository universe -y && add-apt-repository ppa:certbot/certbot -y && apt-get install certbot -y \  
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN cd /lib/systemd/system/sysinit.target.wants/ \
    && ls | grep -v systemd-tmpfiles-setup | xargs rm -f $1

RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/basic.target.wants/* \
    /lib/systemd/system/anaconda.target.wants/* \
    /lib/systemd/system/plymouth* \
    /lib/systemd/system/systemd-update-utmp*


RUN apt-get update && apt-get dselect-upgrade -y && apt-get install sudo  dbus language-pack-en wget lsb-release -y && update-locale LANG=en_US.UTF-8
ENV LANG en_US.utf8

ADD bbb-install.sh /root/bbb-install.sh
RUN chmod +x /root/bbb-install.sh
ENV HOSTIP test.bigbluemeeting.com
ENV MAIL contact@bigbluemeeting.com
RUN echo $(grep $(hostname) /etc/hosts | cut -f1) test.bigbluemeeting.com >> /etc/hosts && /root/bbb-install.sh -v xenial-220 -s ${HOSTIP} -e ${MAIL}
EXPOSE 80 443
EXPOSE 16384-32768/udp

VOLUME ["/var/freeswitch/meetings", "/usr/share/red5/webapps/video/streams", "/var/kurento/recordings", "/var/usr/share/red5/webapps/screenshare/streams", "/var/kurento/screenshare", "/var/bigbluebutton"]


# -- Finish startup
# CMD /root/bbb-install.sh -v xenial-220 -s $HOSTIP -e $MAIL -g
VOLUME [ "/sys/fs/cgroup" ]

CMD ["/lib/systemd/systemd"]


