FROM jenkins/jenkins:lts

ENV DOCKERVERSION=19.03.12

USER root

RUN apt-get update -y \
    && apt-get install -y \
    zip make build-essential libssl-dev zlib1g-dev \
       libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
       libncurses5-dev libncursesw5-dev xz-utils tk-dev liblzma-dev

RUN curl -fsSLO https://www.python.org/ftp/python/3.8.5/Python-3.8.5.tgz \
     && tar -xzvf Python-3.8.5.tgz \
     && rm Python-3.8.5.tgz \
     && cd Python-3.8.5 \
     && ./configure --target=/usr/local \
     && make install

ENV PATH=/var/jenkins_home/.local/bin/:$PATH

RUN curl -fsSLO https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip \
  && unzip awscli-exe-linux-x86_64.zip \
  && ./aws/install -i /usr/local/aws -b /usr/local/bin \
  && rm awscli-exe-linux-x86_64.zip

RUN curl -fsSLO https://releases.hashicorp.com/terraform/0.13.1/terraform_0.13.1_linux_amd64.zip \
  && unzip terraform_0.13.1_linux_amd64.zip -d /usr/local/bin/ \
  && chmod 755 /usr/local/bin/terraform \
  && rm terraform_0.13.1_linux_amd64.zip


USER jenkins
