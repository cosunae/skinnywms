# Build image
# Use slim python 3 + Magics image as base
ARG MAGICS_IMAGE=ecmwf/magics:4.2.4
FROM ${MAGICS_IMAGE}

RUN apt-get update && apt-get install --yes ca-certificates curl fuse \
    && curl -L -O https://github.com/GoogleCloudPlatform/gcsfuse/releases/download/v0.27.0/gcsfuse_0.27.0_amd64.deb \
    && dpkg --install gcsfuse_0.27.0_amd64.deb \
    && mkdir /data

COPY ./_mars-atls13-98f536083ae965b31b0d04811be6f4c6-4RPNlk.grib /data/_mars-atls13-98f536083ae965b31b0d04811be6f4c6-4RPNlk.grib
RUN set -eux \
    && mkdir -p /app/

COPY . /app/skinnywms
RUN pip install /app/skinnywms

# Install Python run-time dependencies.
COPY requirements.txt /root/
RUN set -ex \
    && pip install -r /root/requirements.txt

# demo application will listen at http://0.0.0.0:5000
EXPOSE 5000/tcp

# start demo
# add option --path <directory with grib files>
# to look for grib files in specific directory
CMD python /app/skinnywms/demo.py  --host='0.0.0.0' --port=5000  --path=/data/grib_fc/

# METADATA
# Build-time metadata as defined at http://label-schema.org
# --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`
ARG BUILD_DATE
# --build-arg VCS_REF=`git rev-parse --short HEAD`, e.g. 'c30d602'
ARG VCS_REF
# --build-arg VCS_URL=`git config --get remote.origin.url`, e.g. 'https://github.com/ecmwf/skinnywms'
ARG VCS_URL
# --build-arg VERSION=`git tag`, e.g. '0.2.1'
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
        org.label-schema.name="SkinnyWMS" \
        org.label-schema.description="The SkinnyWMS is a small WMS server that will help you to visualise your NetCDF and Grib Data." \
        org.label-schema.url="https://confluence.ecmwf.int/display/MAGP/Skinny+WMS" \
        org.label-schema.vcs-ref=$VCS_REF \
        org.label-schema.vcs-url=$VCS_URL \
        org.label-schema.vendor="ECMWF - European Centre for Medium-Range Weather Forecasts" \
        org.label-schema.version=$VERSION \
        org.label-schema.schema-version="1.0"
