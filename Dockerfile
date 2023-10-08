FROM continuumio/anaconda3:2023.09-0

WORKDIR /root
# To use a ubuntu and python mirror:
# docker build . --tag scientific-feedback --build-arg DEBIAN_MIRROR=mirrors.ustc.edu.cn --build-arg PYTHON_MIRROR=pypi.tuna.tsinghua.edu.cn
ARG DEBIAN_MIRROR
ARG PYTHON_MIRROR
SHELL ["/bin/bash", "-c"]
ENV no_proxy="localhost, 127.0.0.1, ::1"

COPY . .

# Install build-essential first, or the installation for python package `lmdb` will fail
RUN if [[ ! -z "$DEBIAN_MIRROR" ]] ; then sed -i "s/deb.debian.org/$DEBIAN_MIRROR/g" /etc/apt/sources.list; fi ; \
 apt update && DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends build-essential \
 && if [[ ! -z "$PYTHON_MIRROR" ]] ; then python3 -m pip config set global.index-url https://$PYTHON_MIRROR/simple ; fi ; \
 apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# set timeout in case the pip times out when the package is big
RUN pip config set global.timeout 600 && conda env create -f conda_environment.yml

# RUN conda create -n llm python=3.10 && conda run -n llm pip install -r requirements.txt
RUN pip install -r requirements.txt

# CMD ["bash", "-c", "conda run -n ScienceBeam python -m sciencebeam_parser.service.server --port=8080 & conda run -n llm python main.py"]
CMD ["bash", "-c", "conda run -n ScienceBeam python -m sciencebeam_parser.service.server --port=8080 & python main.py"]
