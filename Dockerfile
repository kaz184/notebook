FROM mambaorg/micromamba:1.5-bullseye-slim

USER root
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    <<EOF
rm -f /etc/apt/apt.conf.d/docker-clean
echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
apt update
apt install -y vim wget curl git sudo jq
echo "$MAMBA_USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
EOF

USER $MAMBA_USER
RUN --mount=target=/opt/conda/pkgs,type=cache,uid=$MAMBA_USER_ID,gid=$MAMBA_USER_GID \
    <<EOF
micromamba install -y -n base -c conda-forge \
    nomkl \
    conda \
    juliaup \
    python=3.10 \
    datar plotnine seaborn \
    jupyterlab jupyterlab-git \
    jax jaxlib dm-haiku \
    datasets \
    scikit-learn sktime catboost optuna \
    r-essentials=4.3 \
    r-irkernel \
    r-patchwork r-ggpubr r-ggpmisc r-ggally r-metr \
    r-reticulate r-tidymodels r-brms r-bh r-mice r-quantreg r-vtree
EOF

WORKDIR /home/$MAMBA_USER
COPY --chown=$MAMBA_USER_ID:$MAMBA_USER_GID <<EOF /home/$MAMBA_USER/.ssh/config
Host github.com
    User git
    IdentityFile /run/secrets/ssh_key
EOF

COPY --chmod=744 --chown=$MAMBA_USER_ID:$MAMBA_USER_GID <<EOF init.sh
#! /bin/bash
juliaup add 1.9

CONDA_JL_HOME=/opt/conda julia -e 'using Pkg; Pkg.add(strip.(readlines()))' <<HERE
    Conda
    RCall
    PythonCall
    IJulia
    MLStyle
    DataFrames
HERE

julia <<HERE
    using IJulia
    for d in readdir(IJulia.kerneldir(), join=true)
        rm(d, recursive=true)
    end
    IJulia.installkernel("Julia")
HERE

sudo chown $(whoami):$(whoami) ~ -R
jupyter lab --ContentsManager.allow_hidden=True --ip=0.0.0.0 --notebook-dir=~/notebook
EOF

ENTRYPOINT [ "/bin/bash", "-ic", "./init.sh" ]