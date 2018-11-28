FROM ubuntu:18.04
LABEL maintainer "help@biothings.io"

ARG BIOTHINGS_VERSION
ARG STUDIO_VERSION
ARG API_NAME
ARG API_VERSION
RUN if [ -z "$BIOTHINGS_VERSION" ]; then echo "NOT SET - use --build-arg BIOTHINGS_VERSION=..."; exit 1; else : ; fi
RUN if [ -z "$STUDIO_VERSION" ]; then echo "NOT SET - use --build-arg STUDIO_VERSION=..."; exit 1; else : ; fi

RUN apt-get -y update
RUN apt-get install -y apt-utils python-yaml python-jinja2 git python3 apt-transport-https curl bash vim tmux sudo npm nodejs dirmngr
# install timezone info, avoid config
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata
# some extra packages for debugging purpose, can be commented out for actual image
RUN if [ -z "$PROD" ]; then apt-get install -y htop ne wget net-tools; fi
RUN git clone http://github.com/ansible/ansible.git /tmp/ansible
WORKDIR /tmp/ansible
ENV PATH /tmp/ansible/bin:/sbin:/usr/sbin:/usr/bin:/bin:/usr/local/bin
ENV ANSIBLE_LIBRARY /tmp/ansible/library
ENV PYTHONPATH /tmp/ansible/lib:$PYTHON_PATH

ADD ansible_playbook /tmp/ansible_playbook
ADD inventory /etc/ansible/hosts

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
RUN if [ -n "$PROD" ]; then rm -rf /tmp/ansible_playbook; fi
RUN if [ -n "$PROD" ]; then rm -rf /tmp/ansible; fi


EXPOSE 8080 9200 7022 7080 27017 22 9000
VOLUME ["/data"]
ENTRYPOINT ["/docker-entrypoint.sh"]
