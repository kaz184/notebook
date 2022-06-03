
FROM jupyter/r-notebook:r-4.1.2

## Julia setup
USER root
WORKDIR /tmp
ENV JULIA_VERSION=1.7.1
RUN wget https://julialang-s3.julialang.org/bin/linux/x64/${JULIA_VERSION%.*}/julia-${JULIA_VERSION}-linux-x86_64.tar.gz
RUN tar -xvzf julia-${JULIA_VERSION}-linux-x86_64.tar.gz
RUN mv julia-${JULIA_VERSION} /opt
RUN ln -s /opt/julia-${JULIA_VERSION}/bin/julia /usr/local/bin/julia
RUN rm julia-${JULIA_VERSION}-linux-x86_64.tar.gz

## Tools
USER root
RUN apt update
RUN apt install -y build-essential nkf jq

## R cmdstan
USER $NB_UID
RUN mamba install -y cmdstan
ENV CMDSTAN=$CONDA_DIR/bin/cmdstan
RUN R -e 'install.packages("cmdstanr", repos = c("https://mc-stan.org/r-packages/", "https://cloud.r-project.org"))'
RUN R -e 'devtools::install_github("IRkernel/repr@936303e4287c36eacc376a9c16a0533aab5a8d7b")'

## Julia Conda, PyCall, RCall
USER $NB_UID
RUN julia -e 'using Pkg; pkg"update"'
RUN julia -e 'using Pkg; pkg"add IJulia"'
ENV CONDA_JL_HOME=$CONDA_DIR
RUN julia -e 'using Pkg; pkg"add Conda; build Conda"'
ENV PYTHON=""
RUN julia -e 'using Pkg; pkg"add PyCall; build PyCall"'
ENV R_HOME=/opt/conda/lib/R
RUN julia -e 'using Pkg; pkg"add RCall; build RCall"'

## Node setup
USER $NB_UID
RUN mamba install -y nodejs==16.*
RUN npm install -g zx
RUN npm install -g puppeteer
USER root
# https://github.com/puppeteer/puppeteer/blob/main/docs/troubleshooting.md#chrome-headless-doesnt-launch-on-unix
RUN apt install -y ca-certificates fonts-liberation libappindicator3-1 libasound2 libatk-bridge2.0-0 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgbm1 libgcc1 libglib2.0-0 libgtk-3-0 libnspr4 libnss3 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 lsb-release wget xdg-utils

## Misc.
USER $NB_UID
RUN mamba install -y jupyterlab-git
COPY ssh_config $HOME/.ssh/config
# to make zx script able to use global modules
ENV NODE_PATH=$CONDA_DIR/lib/node_modules
# ENV JUPYTER_ENABLE_LAB=yes

RUN mamba install -y r-metr r-ggpubr r-ggally
RUN mamba install -y r-mice r-mgcv
RUN julia -e 'using Pkg; pkg"add SymPy"; using SymPy'
RUN julia -e 'using Pkg; pkg"add EventSimulation"; using EventSimulation'
RUN julia -e 'using Pkg; pkg"add DifferentialEquations"; using DifferentialEquations'
RUN julia -e 'using Pkg; pkg"add Parameters"; using Parameters'
# RUN julia -e 'using Pkg; pkg"add MLStyle"; using MLStyle' # this lib has ambiguous scope management so that programs becomes wrong silently
RUN julia -e 'using Pkg; pkg"add Pluto"; using Pluto'
RUN julia -e 'using Pkg; pkg"add PlutoUI"; using PlutoUI'

## Finalize
USER $NB_UID
WORKDIR $HOME
COPY --chmod=u+x init.sh $HOME/init.sh
CMD $HOME/init.sh

