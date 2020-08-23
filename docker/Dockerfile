FROM ubuntu:16.04
VOLUME /etc/ansible
VOLUME /root/.ssh
COPY chaveAnsible /root/.ssh/authorized_keys
COPY interfaces /etc/network/interfaces
RUN apt-get update
RUN apt-get install -y ansible openssh-server
RUN apt-get install -y python3 python3-pip
RUN apt-get install -y iputils-ping nano
RUN apt-get install -y net-tools
RUN apt-get install -y iputils-ping
RUN apt-get install -y whois
RUN pip3 install -r requirements.txt    
RUN echo PermitRootLogin yes >> /etc/ssh/sshd_config
RUN echo 'root:Z010f3c0m' | chpasswd
RUN echo nameserver 172.26.1.100 > /etc/resolv.conf
RUN mkdir -p /var/run/sshd
CMD ["/usr/sbin/sshd", "-D"]
