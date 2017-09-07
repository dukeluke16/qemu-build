#
# qemu-build Dockerfile
#
# https://github.com/dukeluke16/qemu-build/
#

# Pull base image.
FROM ubuntu:17.04
MAINTAINER Luke Thompson <luke@dukeluke.com>
LABEL Description="This image provides a dockerized qemu build environment."

# Set environment variables.
ENV HOME /root
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

# Define working directory.
WORKDIR /root

# Service Build Dependencies
RUN apt-get update && \
    apt-get --yes upgrade && \
    apt-get --yes install \
    unzip \
    zsh \
    gcc make build-essential checkinstall \
    golang-go git \
    openssl libssl-dev \
    python-setuptools python-dev build-essential python-pip \
    qemu qemu-utils && \
    apt-get clean && \
    rm -rf /var/cache/apt/ && \
    pip install --upgrade --no-cache-dir pip setuptools pipenv && \
    rm -rf /tmp/*

# pipenv install
COPY Pipfile /root/Pipfile
COPY Pipfile.lock /root/Pipfile.lock
RUN pipenv install
RUN rm /root/Pipfile
RUN rm /root/Pipfile.lock
#
# TEMPORARY HACK - need to update oss ansible plugin for proper runas support
#
COPY win_package.ps1 /root/win_package.ps1
RUN cd /root/.virtualenvs && \
    cd * && \
    rm lib/python2.7/site-packages/ansible/modules/windows/win_package.ps1 && \
    mv  /root/win_package.ps1 lib/python2.7/site-packages/ansible/modules/windows/win_package.ps1

# configure go
ENV GOPATH $HOME/go
ENV PATH $PATH:$GOROOT/bin:$GOPATH/bin

# Install Zsh
RUN git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh \
      && cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc \
      && chsh -s /bin/zsh && \
      echo 'DISABLE_AUTO_UPDATE="true"' >> ~/.zshrc

# packer install
# packer dev install
RUN go get -u github.com/hashicorp/packer
# packer official 1.0.0 release
# winrm bugs exist in 1.0.0 release use dev install until 1.1.0 release is official
# ADD https://releases.hashicorp.com/packer/1.0.0/packer_1.0.0_linux_amd64.zip /root/.
# RUN unzip packer_1.0.0_linux_amd64.zip && \
#     mv packer /usr/local/bin/ && \
#     rm packer_1.0.0_linux_amd64.zip
ENV PACKER_LOG=1
ENV CHECKPOINT_DISABLE=1

# identify the default port for vnc
EXPOSE 5901

# identify the default port for winrm
EXPOSE 5986

# Set Entrypoint
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
