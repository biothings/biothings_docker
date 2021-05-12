#FROM adoptopenjdk/openjdk11
#java:oracle-java8
FROM ubuntu:20.04
LABEL maintainer "help@biothings.io"

ARG BIOTHINGS_VERSION
ARG STUDIO_VERSION
ARG API_NAME
ARG API_VERSION
RUN if [ -z "$BIOTHINGS_VERSION" ]; then echo "NOT SET - use --build-arg BIOTHINGS_VERSION=..."; exit 1; else : ; fi
RUN if [ -z "$STUDIO_VERSION" ]; then echo "NOT SET - use --build-arg STUDIO_VERSION=..."; exit 1; else : ; fi

ARG DEBIAN_FRONTEND=noninteractive
ARG ELASTICSEARCH_VERSION=6.8.*
ARG MONGODB_VERSION=4.0.*

# both curl & gpg used by apt-key, gpg1 pulls in less deps than gpg2
RUN apt-get -qq -y update && \
    apt-get install -y --no-install-recommends \
    gnupg1 \
    curl \
    ca-certificates && \
    # Add repo for MongoDB
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4 && \
    echo "deb http://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" >> /etc/apt/sources.list.d/mongo-4.0.list && \
    # Elasticsearch
    curl https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add - && \
    echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" >> /etc/apt/sources.list.d/elasticsearch-6.list && \
    # PPA Nginx
    # NOTES:
    #  - adding the PPA repo is now done manually (w/o apt-add-repository)
    #  - will definetly need to update the repo when base image is updated
    #  - may need to fix the key down the line
    # QUESTIONS:
    #  - Why do we need this? this PPA has the same version as the ubuntu repos
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 8B3981E7A6852F782CC4951600A6F0A3C300EE8C && \
    echo "deb http://ppa.launchpad.net/nginx/stable/ubuntu focal main" >> /etc/apt/sources.list.d/ppa-nginx-stable.list && \
    apt-get -y -qq update && \
    # no longer doing upgrades as per:
    #  - codacy's nagging
    #  - the base image is actually quite up to date nowadays
    # apt-get -y upgrade && \
    apt-get -y install --no-install-recommends \
        # base
        apt-utils \
        apt-transport-https \
        bash \
        git \
        vim \
        tmux \
        sudo \
        tzdata \
        python3 \
        openjdk-8-jre-headless \
        # ssh is no longer used
        # openssh-server \
        # client is for ssh-keygen
        openssh-client \
        # only used to add repo, now we just append to the file
        # this pulls in dbus and therefore pulls in systemd
        # software-properties-common \
        # MongoDB
        mongodb-org-server=${MONGODB_VERSION} \
        mongodb-org=${MONGODB_VERSION} \
        mongodb-org-shell=${MONGODB_VERSION} \
        mongodb-org-tools=${MONGODB_VERSION} \
        mongodb-org-mongos=${MONGODB_VERSION} \
        # Nginx
        nginx \
        # Ansible dependency
        python3-yaml \
        python3-jinja2 \
        python3-pip \
    && apt-get install -y \
        # Elasticsearch
        # do this in a separate step because it pre-depends on jre
        # but the package isn't built that well to indicate that
        elasticsearch=${ELASTICSEARCH_VERSION} && \
    if [ -z "$PROD" ]; then \
    apt-get install -y --no-install-recommends \
        htop \
        ne \
        wget \
        net-tools ; \
    fi \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# cerebro
# In the future, we can get the latest release ver. from GitHub APIs
ARG CEREBRO_VERSION=0.9.4
WORKDIR /tmp
RUN curl -LO \
    https://github.com/lmenezes/cerebro/releases/download/v${CEREBRO_VERSION}/cerebro-${CEREBRO_VERSION}.tgz \
    && tar xzf cerebro-${CEREBRO_VERSION}.tgz -C /usr/local \
    && ln -s /usr/local/cerebro-${CEREBRO_VERSION} /usr/local/cerebro \
    && rm -rf /tmp/cerebro*

# vscode code-server for remote code editing
# Commented out on May 12, 2021 -- not frequently used as VSC remote works better
# RUN wget https://github.com/cdr/code-server/releases/download/3.1.1/code-server-3.1.1-linux-x86_64.tar.gz
# RUN tar xzf code-server-3.1.1-linux-x86_64.tar.gz -C /usr/local
# RUN ln -s /usr/local/code-server-3.1.1-linux-x86_64 /usr/local/code-server

RUN git clone http://github.com/ansible/ansible.git /tmp/ansible
WORKDIR /tmp/ansible
# workaround for ansible, still invokes python command
RUN ln -sv /usr/bin/python3 bin/python
# install ansible deps
ENV PATH /tmp/ansible/bin:/sbin:/usr/sbin:/usr/bin:/bin:/usr/local/bin
ENV ANSIBLE_LIBRARY /tmp/ansible/library
ENV PYTHONPATH /tmp/ansible/lib:$PYTHON_PATH

ADD ansible_playbook /tmp/ansible_playbook
ADD inventory /etc/ansible/hosts

ARG GITHASH
RUN echo "GITHASH = $GITHASH"
WORKDIR /tmp/ansible_playbook
RUN if [ -n "$API_NAME" ]; \
    then \
        ansible-playbook studio4api.yml \
            -e "biothings_version=$BIOTHINGS_VERSION" \
            -e "studio_version=$STUDIO_VERSION" \
            -e "api_name=$API_NAME" \
            -e "api_version=$API_VERSION" \
            -c local; \
    else \
        ansible-playbook biothings_studio.yml \
            -e "biothings_version=$BIOTHINGS_VERSION" \
            -e "studio_version=$STUDIO_VERSION" \
            -c local; \
fi

# Clean up ansible_playbook
WORKDIR /tmp
ARG PROD
RUN if [ -n "$PROD" ]; then rm -rf /tmp/ansible_playbook; fi
RUN if [ -n "$PROD" ]; then rm -rf /tmp/ansible; fi


EXPOSE 8080 9200 7022 7080 27017 22 9000
#VOLUME ["/data"]
ENTRYPOINT ["/docker-entrypoint.sh"]
