FROM debian:bullseye-slim


## Prerequisites
USER root
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y sudo wget less nkf jq git build-essential

## Julia
USER root
ENV JULIA_VERSION=1.8.5
RUN wget https://julialang-s3.julialang.org/bin/linux/x64/${JULIA_VERSION%.*}/julia-${JULIA_VERSION}-linux-x86_64.tar.gz -P /tmp && \
    tar -xvzf /tmp/julia-${JULIA_VERSION}-linux-x86_64.tar.gz -C /opt && \
    ln -s /opt/julia-${JULIA_VERSION}/bin/julia /usr/local/bin/julia && \
    rm /tmp/julia-${JULIA_VERSION}-linux-x86_64.tar.gz

## Mamba
USER root
RUN useradd -m docker && \
    echo 'docker:docker' | chpasswd && \
    usermod -aG sudo docker

USER docker
WORKDIR /home/docker

RUN wget "https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-$(uname)-$(uname -m).sh" -P /tmp && \
    bash /tmp/Mambaforge-$(uname)-$(uname -m).sh -b && \
    mambaforge/bin/conda shell.bash hook >> ~/.profile

SHELL [ "/bin/bash", "-lc" ]
RUN mamba init

## R, jupyter, cmdstan and so on with Mamba.
USER docker
RUN mamba install -y \
    cmdstan \
    jupyterlab jupyterlab-git \
    r r-irkernel r-tidyverse \    
    r-patchwork r-ggpubr r-ggpmisc r-ggally r-metr \
    r-brms r-bh \
    r-mgcv \
    r-mice \
    r-quantreg

## Julia Conda, PyCall, RCall
USER docker
RUN julia -e '\
    using Pkg;\
    pkg"\
    update; \
    add IJulia Conda PyCall RCall;\
    add DifferentialEquations;\
    ";\
    using IJulia;\
    installkernel("Julia", "-t auto");\
    '

## cmdstanr
USER docker
RUN R -e '\
    install.packages("cmdstanr", repos = c("https://mc-stan.org/r-packages/", "https://cloud.r-project.org"));\
    '

## Misc.
USER docker
COPY ssh_config /home/docker/.ssh/config

## Finalize
USER docker
COPY --chmod=u+x init.sh /tmp/init.sh
CMD [ "/tmp/init.sh" ]

