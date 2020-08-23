FROM ubuntu:16.04
VOLUME /etc/ansible
COPY chaveAnsible /root/.ssh/authorized_keys
RUN apt-get update
RUN apt-get install -y ansible openssh-server
RUN apt-get install -y python3 python3-pip
RUN apt-get install -y iputils-ping nano
RUN apt-get install -y net-tools
RUN pip3 install pywinrm
RUN echo PermitRootLogin yes >> /etc/ssh/sshd_config
RUN echo 'root:Z010f3c0m' | chpasswd
RUN mkdir -p /var/run/sshd
CMD ["/usr/sbin/sshd", "-D"]
