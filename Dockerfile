
FROM jupyter/r-notebook:r-4.1.1

USER root
WORKDIR /tmp
RUN wget https://julialang-s3.julialang.org/bin/linux/x64/1.7/julia-1.7.0-linux-x86_64.tar.gz
RUN tar -xvzf julia-1.7.0-linux-x86_64.tar.gz
RUN mv julia-1.7.0 /opt
RUN ln -s /opt/julia-1.7.0/bin/julia /usr/local/bin/julia
RUN rm julia-1.7.0-linux-x86_64.tar.gz
RUN apt update
RUN apt install -y build-essential nkf

USER $NB_UID

ENV CONDA_JL_HOME="$CONDA_DIR"
ENV PYTHON=""
ENV R_HOME="$(R RHOME)"

RUN julia -e 'using Pkg; pkg"update; add IJulia"'
RUN CONDA_JL_HOME=$CONDA_DIR julia -e 'using Pkg; pkg"add Conda; build Conda"'
RUN PYTHON="" julia -e 'using Pkg; pkg"add PyCall; build PyCall"'
RUN R_HOME=$(R RHOME) julia -e 'using Pkg; pkg"add RCall; build RCall"'
RUN julia -e 'using Pkg; pkg"add SymPy"; using SymPy'
RUN julia -e 'using Pkg; pkg"add EventSimulation"; using EventSimulation'
RUN julia -e 'using Pkg; pkg"add DifferentialEquations"; using DifferentialEquations'

RUN mamba install -y cmdstan r-metr r-ggpubr r-mgcv r-ggally
ENV CMDSTAN=$CONDA_DIR/bin/cmdstan
RUN R -e 'install.packages("cmdstanr", repos = c("https://mc-stan.org/r-packages/", "https://cloud.r-project.org"))'
RUN R -e 'devtools::install_github("IRkernel/repr@936303e4287c36eacc376a9c16a0533aab5a8d7b")'

RUN mamba install -y jupyterlab-git
ENV JUPYTER_ENABLE_LAB=yes
# ADD startup.jl $HOME/.julia/config/startup.jl

WORKDIR $HOME