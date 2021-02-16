FROM python:3.6

RUN mkdir /data
RUN useradd --user-group -m -d /data/biothings -s /bin/bash biothings

ARG BIOTHINGS_GIT=https://github.com/biothings/biothings.api.git
ARG BIOTHINGS_BRANCH=master

ARG STUDIO_GIT=https://github.com/biothings/biothings_studio.git
ARG STUDIO_BRANCH=master
WORKDIR /data/biothings/biothings_studio
ENV SRC_URI=mongodb://mongodb:27017
ENV SRC_DB=biothings_src
ENV TARGET_URI=mongodb://mongodb:27017
ENV TARGET_DB=biothings_target
ENV HUB_URI=mongodb://mongodb:27017
ENV HUB_DB=biothings_hub
RUN git clone ${STUDIO_GIT} . && git checkout ${STUDIO_BRANCH}
RUN python3 -m venv venv
ENV VIRTUAL_ENV=/data/biothings/biothings_studio/venv
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"
ENV PYTHONPATH=/data/biothings/biothings_studio
# Some dependency of our dependencies (or even deeper dependencies)
#  dedided that they need rustc to build, just this Sunday.
# RUN pip install "cryptography<3.4.0"
 
RUN CRYPTOGRAPHY_DONT_BUILD_RUST=1 pip install -e "git+${BIOTHINGS_GIT}@${BIOTHINGS_BRANCH}#egg=biothings[hub]"
RUN find . -maxdepth 1 -name 'requirements*.txt' -exec pip install -r {} \;

COPY docker-entrypoint.sh /
# fix permissions
RUN chown -R biothings:biothings /data/biothings

# create dirs
USER biothings
RUN ["/bin/bash", "-c", "mkdir -p /data/biothings/{datasources,plugins,dataupload,diff,logs,release,cache,run}"]

VOLUME [ "/data" ]

CMD /docker-entrypoint.sh
