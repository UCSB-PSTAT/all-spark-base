FROM quay.io/jupyter/all-spark-notebook:spark-4.2.0

LABEL maintainer="LSIT Systems <lsitops@ucsb.edu>"

USER root

RUN apt update -qq &&\
    apt install software-properties-common -y &&\
    apt update -qq &&\
    apt upgrade -y &&\
    apt install -y\
    build-essential\
    cmake\
    gfortran\
    git\
    git-lfs\
    jq\
    less\
    libapparmor1\
    libboost-all-dev\
    libcairo2-dev\
    libclang-dev\
    libcurl4-openssl-dev\
    libfftw3-dev\
    libfontconfig1-dev\
    libglpk-dev\
    libnlopt-dev\
    libpq-dev\
    libssh2-1-dev\
    libssl-dev\
    libtiff5-dev\
    libuser\
    libuser1-dev\
    libv8-dev\
    libx11-dev\
    libxml2-dev\
    lmodern\
    lsof\
    psmisc\
    rrdtool\
    wget\
    x11-utils &&\
    apt-get clean &&\
    ## Configure git lfs and R for all system users
    git config --system filter.lfs.clean "git-lfs clean -- %filter-replica" && \
    git config --system filter.lfs.smudge "git-lfs smudge -- %filter-replica" && \
    git config --system filter.lfs.process "git-lfs filter-process" &&\
    Rscript -e "dotR <- file.path(Sys.getenv('HOME'), '.R'); if(!file.exists(dotR)){ dir.create(dotR) }; Makevars <- file.path(dotR, 'Makevars'); if (!file.exists(Makevars)){  file.create(Makevars) }; cat('\nCXX14FLAGS=-O3 -fPIC -Wno-unused-variable -Wno-unused-function', 'CXX14 = g++ -std=c++1y -fPIC', 'CXX = g++', 'CXX11 = g++', 'CC = gcc','FC = /usr/bin/gfortran', file = Makevars, sep = '\n', append = TRUE)"

# Consolidate Conda Installations (Python + R Packages plus any of their configs)
RUN mamba install -y -c conda-forge --freeze-installed \
    imagemagick\
    "jupyter-ai=2.*"\
    jupyterthemes\
    jupyterlab-git\
    jupyter-server-proxy\
    langchain-openai\
    libwebp\
    matplotlib\
    nbgitpuller\
    numpy\
    openai\
    pandas\
    r-igraph\
    r-textshaping\
    r-ragg\
    r-pak\
    r-pkgdown\
    udunits2 &&\
    conda clean -afy &&\
    jupyter server extension enable --py nbgitpuller --sys-prefix &&\
    chown -R $NB_USER:$NB_GID /home/jovyan &&\
    /usr/local/bin/fix-permissions "${CONDA_DIR}" || true

# Rscript Installs and Configs
RUN Rscript -e "install.packages(c('usethis','covr','httr','roxygen2','rversions','imager','patchwork','littler', 'docopt','httr','WDI', 'faraway', 'boot', 'car', 'pscl', 'vcd', 'stargazer', 'effsize', 'Rmisc', 'tidyverse', 'brms', 'rstan', 'ottr'), repos = 'https://cloud.r-project.org/', Ncpus = parallel::detectCores())" &&\
    Rscript -e "pak::pak(c('bradleyboehmke/harrypotter', 'gbm-developers/gbm3'))" &&\
    Rscript -e "pak::cache_clean()" &&\
    rm -rf ~/.cache/R /root/.cache/R /tmp/Rtmp* &&\
    chown -R $NB_USER:$NB_GID /home/jovyan &&\
    /usr/local/bin/fix-permissions "${CONDA_DIR}" || true

COPY extra_config.py /tmp/

COPY spark-logo-rev.svg /opt/

RUN cat /tmp/extra_config.py >> /etc/jupyter/jupyter_server_config.py

USER $NB_USER
