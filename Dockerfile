# FROM ubuntu:20.04

# # Install necessary tools
# RUN apt-get update && apt-get install -y \
#     openssh-server \
#     sudo \
#     net-tools \
#     curl \
#     wget \
#     vim \
#     && apt-get clean

# # Configure SSH
# RUN mkdir /var/run/sshd
# RUN echo 'root:password' | chpasswd
# RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# # Expose SSH port
# EXPOSE 22

# # Entry point
# CMD ["/usr/sbin/sshd", "-D"]

# FROM ubuntu:20.04

# ENV DEBIAN_FRONTEND=noninteractive
# ENV LANG en_US.UTF-8
# ENV LANGUAGE en_US:en
# ENV GOTTY_TAG_VER v1.0.1

# # Install necessary tools
# RUN apt-get update && apt-get install -y \
#     openssh-server \
#     sudo \
#     net-tools \
#     curl \
#     wget \
#     vim \
#     python3-pip \
#     && apt-get clean

# # Install gotty for web-based terminal
# RUN apt-get -y update && \
#     apt-get install -y curl && \
#     curl -sLk https://github.com/yudai/gotty/releases/download/${GOTTY_TAG_VER}/gotty_linux_amd64.tar.gz \
#     | tar xzC /usr/local/bin && \
#     apt-get purge --auto-remove -y curl && \
#     apt-get clean && \
#     rm -rf /var/lib/apt/lists/*

# # Add startup script for Gotty
# COPY /run_gotty.sh /run_gotty.sh
# RUN chmod 744 /run_gotty.sh

# # Configure SSH
# RUN mkdir /var/run/sshd
# RUN echo 'root:password' | chpasswd
# RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# # Expose SSH and Gotty ports
# EXPOSE 22 80

# # Entry point for SSH and Gotty
# CMD ["/bin/bash", "/run_gotty.sh"]

#docker build -t docker-gotty .
FROM ubuntu:latest

WORKDIR /app

ENV PS1 "\n\n> \W \$ "
ENV TERM=linux
ENV PACKAGES bash

#RUN apk --no-cache add $PACKAGES

RUN apt-get update && apt-get -y install wget
ENV GOTTY_BINARY https://github.com/yudai/gotty/releases/download/v1.0.1/gotty_linux_386.tar.gz

RUN wget $GOTTY_BINARY -O gotty.tar.gz && \
    tar -xzf gotty.tar.gz -C /usr/local/bin/ && \
    rm gotty.tar.gz && \
    chmod +x /usr/local/bin/gotty


RUN apt-get update && \
apt-get -y install apt-transport-https \
     ca-certificates \
     curl \
     gnupg2 \
     software-properties-common && \
curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg > /tmp/dkey; apt-key add /tmp/dkey && \
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
   $(lsb_release -cs) \
   stable" && \
apt-get update && \
apt-get -y install docker-ce docker-compose bash

#Bash autocomplete
RUN curl https://raw.githubusercontent.com/docker/docker-ce/master/components/cli/contrib/completion/bash/docker -o /etc/bash_completion.d/docker.sh

#RUN service docker start
EXPOSE 8080

COPY files/home/* /root/
COPY app $WORKDIR

RUN git clone https://github.com/eshnil2000/traefik-docker-browser-letsencrypt.git /app/workshop
ENTRYPOINT ["sh", "-c"]
CMD ["service docker start && gotty -w docker run -v /var/run/docker.sock:/var/run/docker.sock -it --rm docker-gotty /bin/bash"]
#CMD ["gotty --permit-write --reconnect bash"]