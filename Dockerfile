FROM ubuntu:16.04
MAINTAINER sami.khan@bigbluemeeting.com

ENV DEBIAN_FRONTEND noninteractive
# RUN echo 'Acquire::http::Proxy "http://192.168.2.69:3142";'  > /etc/apt/apt.conf.d/01proxy
RUN apt-get update && apt-get dselect-upgrade -y
ADD bbb-install/bbb-install.sh /root/bbb-install.sh
RUN chmod +x /root/bbb-install.sh
ENV hostip test.bigbluemeeting.com
ENV mail contact@bigbluemeeting.com
RUN /root/bbb-install.sh ${hostip} -s ${hostip} -e ${mail} -g

# -- Finish startup
CMD []
