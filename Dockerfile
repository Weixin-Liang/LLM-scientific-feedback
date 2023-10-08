# This dockerfile does not include the sciencebeam-parser. Use the docker compose file to run both sciencebeam-parser and the application.
# docker build . --tag scientific-feedback --build-arg UBUNTU_MIRROR=mirrors.ustc.edu.cn --build-arg PYTHON_MIRROR=pypi.tuna.tsinghua.edu.cn
FROM ubuntu:22.04

WORKDIR /root
# To use a ubuntu and python mirror:
ARG UBUNTU_MIRROR
ARG PYTHON_MIRROR
SHELL ["/bin/bash", "-c"]
ENV no_proxy="localhost, 127.0.0.1, ::1"

COPY . .

# change python index and install dependency
RUN if [[ ! -z "$UBUNTU_MIRROR" ]] ; then sed -i "s/archive.ubuntu.com/$UBUNTU_MIRROR/g" /etc/apt/sources.list \
 && sed -i "s/security.ubuntu.com/$UBUNTU_MIRROR/g" /etc/apt/sources.list ; fi ; \
 apt update && DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends python3-pip \
 && if [[ ! -z "$PYTHON_MIRROR" ]] ; then python3 -m pip config set global.index-url https://$PYTHON_MIRROR/simple ; fi ; \
 pip install -r requirements.txt \
 && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["python3", "main.py"]
