# Build WebApp
FROM node:14 AS build-webapp

ARG WEBAPP_GIT=https://github.com/biothings/biothings_studio.git
ARG WEBAPP_VERSION=master

WORKDIR /build/src/github.com/biothings/biothings_studio
RUN git clone ${WEBAPP_GIT} .
RUN git checkout ${WEBAPP_VERSION}
WORKDIR /build/src/github.com/biothings/biothings_studio/webapp
RUN npm install && npm run build --legacy-peer-deps

# Build Python wheels
FROM ubuntu:20.04 AS build-wheels
ARG API_NAME
WORKDIR /build/wheels
RUN apt update && apt install -y --no-install-recommends python3 python3-pip python3-dev gcc
RUN echo "$API_NAME"
# If we only intend to install on specific APIs, we only build for that
RUN if [ "$API_NAME" = "myvariant.info" ]; \
	then \
		python3 -m pip wheel bitarray==0.8.1; \
	fi;

# Build Final Image
FROM ubuntu:20.04
LABEL maintainer "help@biothings.io"

ARG PROD
ARG BIOTHINGS_VERSION
ARG STUDIO_VERSION
ARG API_NAME
ARG API_VERSION

RUN if [ -z "$BIOTHINGS_VERSION" ]; then echo "NOT SET - use --build-arg BIOTHINGS_VERSION=..."; exit 1; else : ; fi
RUN if [ -z "$STUDIO_VERSION" ]; then echo "NOT SET - use --build-arg STUDIO_VERSION=..."; exit 1; else : ; fi

ARG DEBIAN_FRONTEND=noninteractive
ARG ELASTICSEARCH_VERSION=7.13.*         # use to specify a specific Elasticsearch version to install
ARG ELASTICSEARCH_VERSION_REPO=7.x       # use to specify a specific Elasticsearch version repo to load, e.g. 6.x or 7.x
ARG MONGODB_VERSION=4.4.*                # use to specify a specific MongoDB version to install
ARG MONGODB_VERSION_REPO=4.4             # use to specify a specific MongoDB version repo to load
# In the future, we can get the latest release ver. from GitHub APIs
ARG CEREBRO_VERSION=0.9.4

# both curl & gpg used by apt-key, gpg1 pulls in less deps than gpg2
# lsb-release is used to get the ubuntu code name like focal
RUN apt-get -qq -y update && \
    apt-get install -y --no-install-recommends \
    gnupg1 \
    curl \
    ca-certificates \
    lsb-release && \
    release=`lsb_release -sc` && \
    # Add repo for MongoDB
    curl "https://www.mongodb.org/static/pgp/server-${MONGODB_VERSION_REPO}.asc" | apt-key add - && \
    # apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4 && \
    # echo "deb http://repo.mongodb.org/apt/ubuntu /mongodb-org/4.0 multiverse" >> /etc/apt/sources.list.d/mongo-4.0.list && \
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu ${release}/mongodb-org/${MONGODB_VERSION_REPO} multiverse" | tee /etc/apt/sources.list.d/mongodb-org-${MONGODB_VERSION_REPO}.list && \
    # Elasticsearch
    curl https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add - && \
    echo "deb https://artifacts.elastic.co/packages/${ELASTICSEARCH_VERSION_REPO}/apt stable main" >> /etc/apt/sources.list.d/elasticsearch-${ELASTICSEARCH_VERSION_REPO}.list && \
    # PPA Nginx
    # NOTES:
    #  - adding the PPA repo is now done manually (w/o apt-add-repository)
    #  - will definetly need to update the repo when base image is updated
    #  - may need to fix the key down the line
    # QUESTIONS:
    #  - Why do we need this? this PPA has the same version as the ubuntu repos
    # Comment out Nginx PPA repo below, can be re-enabled when we need a newer version of Nginx
    # apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 8B3981E7A6852F782CC4951600A6F0A3C300EE8C && \
    # echo "deb http://ppa.launchpad.net/nginx/stable/ubuntu focal main" >> /etc/apt/sources.list.d/ppa-nginx-stable.list && \
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
        tmux \
        sudo \
        less \
        tzdata \
        python3 \
        net-tools \
        # jdk is no longer needed since Elasticsearch v7, now has
        # since it has a bundled openjdk included.
        # openjdk-8-jre-headless \
        # ssh is no longer used
        # openssh-server \
        # client is for ssh-keygen
        # openssh-client \
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
		# Virtualenv
		python3-virtualenv && \
    # install JDK only when ES < v7
    if [ `echo $ELASTICSEARCH_VERSION | cut -d '.' -f1` -lt 7 ];  then \
        apt-get install -y --no-install-recommends openjdk-11-jre-headless ; \
    fi && \
    apt-get install -y --no-install-recommends \
        # Elasticsearch
        # do this in a separate step because it pre-depends on jre
        # but the package isn't built that well to indicate that
        elasticsearch=${ELASTICSEARCH_VERSION} && \
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

# cerebro
WORKDIR /tmp
RUN curl -LO \
    https://github.com/lmenezes/cerebro/releases/download/v${CEREBRO_VERSION}/cerebro-${CEREBRO_VERSION}.tgz \
    && tar xzf cerebro-${CEREBRO_VERSION}.tgz -C /usr/local \
    && ln -s /usr/local/cerebro-${CEREBRO_VERSION} /usr/local/cerebro \
    && rm -rf /tmp/cerebro*


RUN useradd -m biothings -s /bin/bash
WORKDIR /home/biothings
USER biothings
COPY --from=build-wheels --chown=biothings:biothings /build/wheels /home/biothings/wheels
RUN virtualenv -p python3 /home/biothings/pyenv
# Check for potentially empty list of wheels
RUN for whl_file in /home/biothings/wheels/*.whl; \
	do \
		test ! -f "$whl_file" || /home/biothings/pyenv/bin/pip3 install "$whl_file"; \
	done
COPY --chown=biothings:biothings files/biothings_studio	/home/biothings/biothings_studio
COPY --chown=biothings:biothings \
	files/ssh-keygen.py \
	/home/biothings/utilities/
USER root
RUN rm -rf /home/biothings/wheels

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

COPY --from=build-webapp --chown=root:www-data /build/src/github.com/biothings/biothings_studio/webapp/dist /srv/www/webapp

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

RUN if [ -n "${API_NAME}" ]; \
	then \
		ln -s /home/biothings/biothings_studio/bin/ssh_host_key "/home/biothings/${API_NAME}/src/bin/ssh_host_key"; \
	fi

# Clean up ansible_playbook
WORKDIR /tmp
RUN if [ -n "$PROD" ]; then rm -rf /tmp/ansible_playbook; fi
RUN if [ -n "$PROD" ]; then rm -rf /tmp/ansible; fi


EXPOSE 8080 9200 7022 7080 27017 22 9000
#VOLUME ["/data"]
ENTRYPOINT ["/docker-entrypoint.sh"]
