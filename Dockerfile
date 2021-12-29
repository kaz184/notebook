
FROM jupyter/r-notebook:r-4.1.2

USER root
WORKDIR /tmp

ENV JULIA_VERSION=1.7.1
RUN wget https://julialang-s3.julialang.org/bin/linux/x64/${JULIA_VERSION%.*}/julia-${JULIA_VERSION}-linux-x86_64.tar.gz
RUN tar -xvzf julia-${JULIA_VERSION}-linux-x86_64.tar.gz
RUN mv julia-${JULIA_VERSION} /opt
RUN ln -s /opt/julia-${JULIA_VERSION}/bin/julia /usr/local/bin/julia
RUN rm julia-${JULIA_VERSION}-linux-x86_64.tar.gz

RUN apt update
RUN apt install -y build-essential nkf

USER $NB_UID

RUN mamba install -y cmdstan
ENV CMDSTAN=$CONDA_DIR/bin/cmdstan
RUN R -e 'install.packages("cmdstanr", repos = c("https://mc-stan.org/r-packages/", "https://cloud.r-project.org"))'
RUN R -e 'devtools::install_github("IRkernel/repr@936303e4287c36eacc376a9c16a0533aab5a8d7b")'
RUN mamba install -y r-metr r-ggpubr r-mgcv r-ggally

RUN julia -e 'using Pkg; pkg"update"'
RUN julia -e 'using Pkg; pkg"add IJulia"'
ENV CONDA_JL_HOME=$CONDA_DIR
RUN julia -e 'using Pkg; pkg"add Conda; build Conda"'
ENV PYTHON=""
RUN julia -e 'using Pkg; pkg"add PyCall; build PyCall"'
ENV R_HOME=/opt/conda/lib/R
RUN julia -e 'using Pkg; pkg"add RCall; build RCall"'
# RUN julia -e 'using Pkg; pkg"add SymPy"; using SymPy'
# RUN julia -e 'using Pkg; pkg"add EventSimulation"; using EventSimulation'
# RUN julia -e 'using Pkg; pkg"add DifferentialEquations"; using DifferentialEquations'

RUN mamba install -y jupyterlab-git
ENV JUPYTER_ENABLE_LAB=yes
# ADD startup.jl $HOME/.julia/config/startup.jl

WORKDIR $HOME