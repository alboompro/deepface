#base image
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu20.04

# ENV NV_CUDNN_VERSION=8.6.0
# ENV NV_CUDNN_PACKAGE=libcudnn8=8.6.0+cuda11.4
# LABEL com.nvidia.cudnn.version=8.6.0

# Set environment to noninteractive (this prevents some prompts)
ENV DEBIAN_FRONTEND=noninteractive

# Install some basic utilities and dependencies
RUN apt-get update && apt-get install -y \
  sudo \
  curl \
  wget \
  build-essential \
  ffmpeg \
  libsm6 \
  libxext6 \
  libxrender-dev \
  libglib2.0-0 \
  python3.8 \
  python3-pip \
  && pip install --upgrade pip \
  && rm -rf /var/lib/apt/lists/*

# Install miniconda
# ENV CONDA_DIR /opt/conda
# RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
#   /bin/bash ~/miniconda.sh -b -p /opt/conda

ENV PATH=$CONDA_DIR/bin:$PATH
ENV DEBIAN_FRONTEND=

# create required folder
RUN mkdir -p /app/deepface

# Copy required files from repo into image
COPY ./deploy/startup.sh /app/startup.sh
COPY ./deepface /app/deepface
COPY ./newrelic.ini /app/newrelic.ini
COPY ./api/app.py ./api/routes.py ./requirements.txt ./api/service.py ./setup.py ./README.md  /app/

# switch to application directory 
WORKDIR /app

# RUN conda install -c conda-forge cudatoolkit=11.8.0 && \
# pip install nvidia-cudnn-cu11==8.6.0.163 tensorflow==2.13.*

# RUN mkdir -p $CONDA_DIR/etc/conda/activate.d
# RUN echo 'CUDNN_PATH=$(dirname $(python -c "import nvidia.cudnn;print(nvidia.cudnn.__file__)"))' >> $CONDA_DIR/etc/conda/activate.d/env_vars.sh
# RUN echo 'export LD_LIBRARY_PATH=$CUDNN_PATH/lib:$CONDA_DIR/lib/:$LD_LIBRARY_PATH' >> $CONDA_DIR/etc/conda/activate.d/env_vars.sh
# RUN . $CONDA_DIR/etc/conda/activate.d/env_vars.sh
# RUN pip install tensorflow==2.12.0

RUN pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host=files.pythonhosted.org -e .

RUN curl -Ls https://download.newrelic.com/install/newrelic-cli/scripts/install.sh | bash && \
  sudo NEW_RELIC_API_KEY=NRAK-J3DXRVVCUR20SUVZ0Y0QU9PTG05 \
  NEW_RELIC_ACCOUNT_ID=1393404 /usr/local/bin/newrelic install -n logs-integration

# environment variables
ENV PYTHONUNBUFFERED=1

# run the app (re-configure port if necessary)
EXPOSE 5000
