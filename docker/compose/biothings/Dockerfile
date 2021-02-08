FROM python:3.6

RUN mkdir /data
RUN useradd --user-group -m -d /data/biothings -s /bin/bash biothings

WORKDIR /data/biothings/biothings.api
# fetch biothings.api
ARG BIOTHINGS_GIT=https://github.com/biothings/biothings.api.git
ARG BIOTHINGS_BRANCH=master
RUN echo Pulling BioThings.API from ${BIOTHINGS_GIT}:${BIOTHINGS_BRANCH}
RUN git clone ${BIOTHINGS_GIT} . && git checkout ${BIOTHINGS_BRANCH}
RUN python3 -m venv venv
ENV VIRTUAL_ENV=/data/biothings/biothings.api/venv
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"
# Some dependency of our dependencies (or even deeper dependencies)
#  dedided that they need rustc to build, just this Sunday.
RUN pip install "cryptography<3.4.0"
RUN pip install .[hub]
# remove biothings
RUN pip uninstall -y biothings

# fetch studio
ARG STUDIO_GIT=https://github.com/biothings/biothings_studio.git
ARG STUDIO_BRANCH=master
WORKDIR /data/biothings/biothings_studio
RUN git clone ${STUDIO_GIT} . && git checkout ${STUDIO_BRANCH}
RUN ln -sv /data/biothings/biothings.api/biothings .
ENV PYTHONPATH=/data/biothings/biothings_studio
# replace config file
COPY config.py .
# fix permissions
RUN chown -R biothings:biothings /data/biothings

# create dirs
USER biothings
RUN mkdir -p /data/biothings/{datasources,plugins,dataupload,diff,logs,release,cache,run}

VOLUME [ "/data" ]

# FIXME: now we still need SSH Key
CMD /data/biothings/biothings_studio/bin/hub.py
