# https://pythonspeed.com/articles/conda-docker-image-size/
# https://jcristharif.com/conda-docker-tips.html

FROM debian:bullseye-slim


## Prerequisites
USER root
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y sudo wget curl procps less nkf jq git build-essential

## Mamba
USER root
RUN useradd -m docker \
    && echo 'docker:docker' | chpasswd \
    && usermod -aG sudo docker

USER docker
WORKDIR /home/docker

RUN wget "https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-pypy3-$(uname)-$(uname -m).sh" -P /tmp \
    && bash /tmp/Mambaforge-pypy3-$(uname)-$(uname -m).sh -b \
    && rm /tmp/Mambaforge-pypy3-$(uname)-$(uname -m).sh \
    && mambaforge-pypy3/bin/conda shell.bash hook >> ~/.profile

## R, jupyter, cmdstan and so on with Mamba.
SHELL [ "/bin/bash", "-lc" ]
RUN mamba init \
    && mamba create -n notebook -y \
    nomkl \
    python=3.9 \
    r-essentials=4.2 \
    cmdstan \
    jupyterlab jupyterlab-git \
    r-patchwork r-ggpubr r-ggpmisc r-ggally r-metr \
    r-brms r-bh r-mice r-quantreg r-vtree \
    jax jaxlib dm-haiku datasets scikit-learn sktime \
    && mamba clean -afy

## cmdstanr
USER docker
RUN mamba run -n notebook R -e '\
    install.packages("cmdstanr", repos = c("https://mc-stan.org/r-packages/", "https://cloud.r-project.org"));\
    '

## Misc.
USER docker
COPY ssh_config /home/docker/.ssh/config

## Python
# 2.85 GB
# RUN mamba install -n notebook -y pytorch torchvision torchaudio cpuonly -c pytorch 
# RUN mamba run -n notebook pip install jax jaxlib dm-haiku datasets scikit-learn sktime

## Julia
RUN curl -fsSL https://install.julialang.org | sh -s -- -y --default-channel 1.9 
RUN mamba run -n notebook julia -e 'using Pkg; pkg"add IJulia"'

## Finalize
USER docker
COPY --chmod=u+x init.sh /tmp/init.sh
CMD [ "/tmp/init.sh" ]

