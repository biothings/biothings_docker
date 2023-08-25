# Build Python wheels
# FROM ubuntu:22.04 AS build-wheels
# ARG API_NAME
# WORKDIR /build/wheels
# RUN apt update && apt install -y --no-install-recommends python3 python3-pip python3-dev gcc
# RUN echo "$API_NAME"
# # If we only intend to install on specific APIs, we only build for that
# RUN if [ "$API_NAME" = "myvariant.info" ]; \
# 	then \
# 		python3 -m pip wheel bitarray==0.8.1; \
# 	fi;

# Build Final Image
FROM ubuntu:22.04
LABEL maintainer "help@biothings.io"

ARG PROD
ARG TEST

ARG BIOTHINGS_REPOSITORY
ARG BIOTHINGS_VERSION
ARG API_NAME
ARG API_VERSION
ARG AWS_ACCESS_KEY
ARG AWS_SECRET_KEY
ARG ES_HOST
ARG MONGO_HOST

RUN if [ -z "$BIOTHINGS_VERSION" ]; then echo "NOT SET - use --build-arg BIOTHINGS_VERSION=..."; exit 1; else : ; fi

ARG DEBIAN_FRONTEND=noninteractive

# both curl & gpg used by apt-key, gpg1 pulls in less deps than gpg2
# lsb-release is used to get the ubuntu code name like focal
RUN apt-get -qq -y update && \
    apt-get -y install --no-install-recommends \
        # base
        apt-utils \
        apt-transport-https \
        bash \
        git \
        tmux \
        sudo \
        less \
        tzdata \
        python3 \
        net-tools \
        # ssh is no longer used
        # openssh-server \
        # client is for ssh-keygen
        # openssh-client \
        # only used to add repo, now we just append to the file
        # this pulls in dbus and therefore pulls in systemd
        # software-properties-common \
        # Ansible dependency
        python3-yaml \
        python3-jinja2 \
		python3-pip \
		# Virtualenv
		python3-virtualenv && \
    # install some useful tools when $PROD is not set
    if [ -z "$PROD" ]; then \
    apt-get install -y --no-install-recommends \
        htop \
        ne \
        vim \
        wget ; \
    fi && \
    # for building orjson on aarch64. Somehow the wheel does not work so
    # it has to be built from scratch
    if [ $(dpkg --print-architecture)=='arm64' ]; then \
    apt-get install -y --no-install-recommends \
      rustc \
      cargo \
      python3-dev ;\
    fi && \
    apt-get clean -y && apt-get autoclean -y && apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

ARG PYTHON_VERSION

# Install required packages and create user.
RUN if [ -n "$PYTHON_VERSION" ]; then \
        apt update -y -qq && \
        apt install -y --no-install-recommends \
            build-essential \
            libssl-dev \
            libffi-dev \
            libsqlite3-dev \
            liblzma-dev && \
        apt clean -y && apt autoclean -y && apt autoremove -y && \
        rm -rf /var/lib/apt/lists/* ; \
    fi

RUN useradd -m biothings -s /bin/bash

WORKDIR /home/biothings
USER biothings

# Install pyenv if PYTHON_VERSION is set.
RUN if [ -n "$PYTHON_VERSION" ]; then \
        git clone https://github.com/yyuu/pyenv.git ~/.pyenv && \
        $HOME/.pyenv/bin/pyenv install $PYTHON_VERSION && \
        virtualenv -p $HOME/.pyenv/versions/$PYTHON_VERSION/bin/python /home/biothings/pyenv && \
        wget https://bootstrap.pypa.io/get-pip.py && \
        /home/biothings/pyenv/bin/python get-pip.py && \
        /home/biothings/pyenv/bin/pip install --upgrade --force-reinstall setuptools; \
    else \
        virtualenv -p python3 /home/biothings/pyenv; \
    fi

# Install Python packages from wheels.
RUN for whl_file in /home/biothings/wheels/*.whl; do \
        test ! -f "$whl_file" || /home/biothings/pyenv/bin/pip3 install "$whl_file"; \
    done

COPY --chown=biothings:biothings files/biothings_studio	/home/biothings/biothings_studio
COPY --chown=biothings:biothings \
	files/ssh-keygen.py \
	/home/biothings/utilities/
# Setup bash & tmux for biothings user
COPY --chown=biothings:biothings files/.tmux.conf	/home/biothings/.tmux.conf
COPY --chown=biothings:biothings files/.inputrc	/home/biothings/.inputrc
COPY --chown=biothings:biothings files/.git_aliases	/home/biothings/.git_aliases
RUN bash -c "echo -e '\nalias psg=\"ps aux|grep\"\nsource ~/.git_aliases\n' >> ~/.bashrc"
USER root
# RUN rm -rf /home/biothings/wheels

# vscode code-server for remote code editing
# Commented out on May 12, 2021 -- not frequently used as VSC remote works better
# RUN wget https://github.com/cdr/code-server/releases/download/3.1.1/code-server-3.1.1-linux-x86_64.tar.gz
# RUN tar xzf code-server-3.1.1-linux-x86_64.tar.gz -C /usr/local
# RUN ln -s /usr/local/code-server-3.1.1-linux-x86_64 /usr/local/code-server

RUN git clone http://github.com/ansible/ansible.git -b stable-2.12 /tmp/ansible
WORKDIR /tmp/ansible
# workaround for ansible, still invokes python command
RUN ln -sv /usr/bin/python3 bin/python
# install ansible deps
ENV PATH /tmp/ansible/bin:/sbin:/usr/sbin:/usr/bin:/bin:/usr/local/bin
ENV ANSIBLE_LIBRARY /tmp/ansible/library
ENV PYTHONPATH /tmp/ansible/lib:$PYTHON_PATH

ADD ansible_playbook /tmp/ansible_playbook
ADD inventory /etc/ansible/hosts

ARG ES_HEAP_SIZE

WORKDIR /tmp/ansible_playbook
RUN if [ -n "$API_NAME" ]; \
    then \
        ansible-playbook studio4api.yml \
            -e "biothings_version=$BIOTHINGS_VERSION" \
            -e "api_name=$API_NAME" \
            -e "api_version=$API_VERSION" \
            -e "es_heap_size=$ES_HEAP_SIZE" \
            -e "es_host=$ES_HOST" \
            -e "mongo_host=$MONGO_HOST" \
            -c local; \
    else \
        ansible-playbook biothings_studio.yml \
            -e "biothings_version=$BIOTHINGS_VERSION" \
            -e "biothings_repository=$BIOTHINGS_REPOSITORY" \
            -e "es_heap_size=$ES_HEAP_SIZE" \
            -e "es_host=$ES_HOST" \
            -e "mongo_host=$MONGO_HOST" \
            -c local; \
fi

RUN if [ -n "${API_NAME}" ]; \
	then \
		ln -s /home/biothings/biothings_studio/bin/ssh_host_key "/home/biothings/${API_NAME}/src/bin/ssh_host_key"; \
	fi

# Clean up ansible_playbook
WORKDIR /tmp
RUN if [ -n "$PROD" ]; then rm -rf /tmp/ansible_playbook; fi
RUN if [ -n "$PROD" ]; then rm -rf /tmp/ansible; fi

EXPOSE 7022 7080 27017 22
#VOLUME ["/data"]
ENTRYPOINT ["/docker-entrypoint.sh"]
