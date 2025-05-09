FROM quay.io/jupyter/all-spark-notebook:spark-3.5.3

LABEL maintainer="LSIT Systems <lsitops@ucsb.edu>"

USER root

RUN apt update -qq && \
    apt install software-properties-common -y && \
    apt update -qq && \
    apt upgrade -y && \
    apt install -y \
        jq \
        lsof \
        less \
        libapparmor1 \
        libtiff5-dev \
        libfftw3-dev \
        libcairo2-dev \
        libx11-dev \
        x11-utils \
        psmisc \
        libclang-dev \
        gfortran \
        libglpk-dev \
        libv8-dev \
        libssh2-1-dev \
        git \
        git-lfs \
        curl \
        libuser \
        libuser1-dev \
        libpq-dev \
        rrdtool \
        build-essential \
        libxml2-dev \
        libcurl4-openssl-dev \
        libssl-dev \
        build-essential \
        cmake \
        libnlopt-dev \
        libboost-all-dev \
        wget \
        lmodern && \
        apt-get clean

RUN pip install nbgitpuller && \
    jupyter server extension enable --py nbgitpuller --sys-prefix

RUN conda install -y -c conda-forge libwebp

RUN conda install -y -c conda-forge --freeze-installed jupyterthemes jupyter-server-proxy udunits2 imagemagick pandas numpy r-igraph && \
    conda clean --all

RUN pip install matplotlib

RUN jupyter server extension enable --sys-prefix jupyter_server_proxy

# Inject Compiler flags for R
RUN R -e "dotR <- file.path(Sys.getenv('HOME'), '.R'); if(!file.exists(dotR)){ dir.create(dotR) }; Makevars <- file.path(dotR, 'Makevars'); if (!file.exists(Makevars)){  file.create(Makevars) }; cat('\nCXX14FLAGS=-O3 -fPIC -Wno-unused-variable -Wno-unused-function', 'CXX14 = g++ -std=c++1y -fPIC', 'CXX = g++', 'CXX11 = g++', 'CC = gcc','FC = /usr/bin/gfortran', file = Makevars, sep = '\n', append = TRUE)"

RUN R -e "install.packages(c('usethis', 'covr', 'devtools', 'httr', 'roxygen2', 'rversions', 'imager', 'patchwork', 'littler', 'docopt', 'WDI', 'faraway', 'boot', 'car', 'pscl', 'vcd', 'stargazer', 'effsize', 'Rmisc', 'tidyverse', 'brms', 'rstan'), repos = 'https://cloud.r-project.org/', Ncpus = parallel::detectCores())"

RUN R -e "devtools::install_github('bradleyboehmke/harrypotter')"

RUN R -e "devtools::install_github('gbm-developers/gbm3')"

RUN R -e "devtools::install_github('ucbds-infra/ottr@stable')"

COPY extra_config.py /tmp/

COPY spark-logo-rev.svg /opt/

RUN cat /tmp/extra_config.py >> /etc/jupyter/jupyter_server_config.py

RUN /usr/local/bin/fix-permissions "${CONDA_DIR}" || true

RUN chown -R jovyan:users /home/jovyan

USER $NB_USER

RUN git lfs install
