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
# base
RUN apt-get -y -qq update && apt-get -y -qq upgrade && \
    apt-get -y -qq install \
    apt-utils \
    apt-transport-https \
    software-properties-common \
    bash \
    curl \
    git \
    vim \
    tmux \
    sudo \
    tzdata \
    python3 \
    openjdk-8-jre-headless 
    # openssh-server \


# some extra packages for debugging purpose, can be commented out for actual image
RUN if [ -z "$PROD" ]; then apt-get -y -q install htop ne wget net-tools; fi

ARG ELASTICSEARCH_VERSION=6.8.*
# elastic
RUN curl https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add - && \
    apt-add-repository "deb https://artifacts.elastic.co/packages/6.x/apt stable main" && \
    apt-get -y -qq install elasticsearch=${ELASTICSEARCH_VERSION}
# mongo
# TODO: update the version later
#  This commit broke installing in a docker container
#  https://github.com/mongodb/mongo/commit/08e22cf1dbc7f28db4ff0711b2feb166d776c2d8#diff-2c47e73d74099557344473c7c23c11843015cfd12316d1d19ba5b008dfa6ece2
#  Apparently they made some modifications to not assume systemd that's probably going to be out in the next version
#  But somehow we have systemd installed (probably pulled in as a dependency of something)
# FIXME: (Upadted 2021.05) 
#  Yeah that check indeed does not fix the problem -- because we have systemd
#  and systemd is pulled in by OpenSSH
#  so we are more or less stuck on 4.0.20 unless we do hacky workarounds
#  (like replacing systemd with some dummpy package)
#  don't do this:
#    RUN dpkg -r --force-depends systemd
ARG MONGODB_VERSION=4.0.*
# workaround for systemctl
RUN ln -s /bin/true /usr/sbin/systemctl
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4 && \
    apt-add-repository "deb http://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" && \
    apt-get -y -qq install mongodb-org-server=${MONGODB_VERSION} mongodb-org=${MONGODB_VERSION} \
        mongodb-org-shell=${MONGODB_VERSION} \
        mongodb-org-tools=${MONGODB_VERSION} \
        mongodb-org-mongos=${MONGODB_VERSION}
# unset workaround for systemctl
RUN rm -f /usr/sbin/systemctl
# nginx
RUN apt-add-repository "ppa:nginx/stable" && apt-get  -y -qq install nginx
# cerebro
ARG CEREBRO_VERSION=0.9.4
WORKDIR /tmp
RUN wget https://github.com/lmenezes/cerebro/releases/download/v${CEREBRO_VERSION}/cerebro-${CEREBRO_VERSION}.tgz
RUN tar xzf cerebro-${CEREBRO_VERSION}.tgz -C /usr/local
RUN ln -s /usr/local/cerebro-${CEREBRO_VERSION} /usr/local/cerebro

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
RUN apt install -y python3-yaml python3-jinja2 python3-pip 
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
RUN if [ -n "$PROD" ]; then apt-get clean; fi
RUN if [ -n "$PROD" ]; then rm -fr /tmp/cerebro*; fi


EXPOSE 8080 9200 7022 7080 27017 22 9000
#VOLUME ["/data"]
ENTRYPOINT ["/docker-entrypoint.sh"]
