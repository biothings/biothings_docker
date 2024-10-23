FROM ubuntu:24.04
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

RUN useradd -m biothings -s /bin/bash

WORKDIR /home/biothings
USER biothings

RUN virtualenv -p python3 /home/biothings/pyenv

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

RUN git clone https://github.com/ansible/ansible.git -b stable-2.17 /tmp/ansible
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

EXPOSE 7022 7080 22
ENTRYPOINT ["/docker-entrypoint.sh"]
