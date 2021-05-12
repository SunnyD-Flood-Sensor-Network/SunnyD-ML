FROM rocker/r-ver:4.0.5

# system libraries of general use
## install debian packages
RUN apt-get update -qq && apt-get -y --no-install-recommends install \
    file \
    libedit2 \
    libssl-dev \
    lsb-release \
    psmisc \
    procps \
    wget \
    zlib1g-dev \
    libxml2-dev \
    libpq-dev \
    libssh2-1-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libmagick++-dev && \
    rm -rf /var/lib/apt/lists/

## update system libraries
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean

# install miniconda, and set the appropriate path variables.
# install Python 3.7 (Miniconda) and Tensorflow Python packages then set path variables.
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-py39_4.9.2-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc
ENV PATH /opt/conda/bin:$PATH

# install tensorflow and h5py using the pip that links to miniconda (the default pip is for python 2.7)
RUN /opt/conda/bin/conda install tensorflow keras pillow && \
    /opt/conda/bin/conda clean -tipsy

# let R know the right version of python to use
ENV RETICULATE_PYTHON /opt/conda/bin/python
    
# install packages
RUN install2.r plumber tensorflow keras magick

RUN groupadd -r plumber && useradd --no-log-init -r -g plumber plumber

ADD ml/MN2_model_TB home/plumber/ml/MN2_model_TB
ADD plumber.R /home/plumber/plumber.R
ADD entrypoint.R /home/plumber/entrypoint.R

EXPOSE 8001

WORKDIR /home/plumber
USER plumber
CMD Rscript entrypoint.R