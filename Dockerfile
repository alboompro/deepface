#base image
FROM nvidia/cuda:11.4.3-cudnn8-runtime-ubuntu20.04

# ENV NV_CUDNN_VERSION=8.6.0
# ENV NV_CUDNN_PACKAGE=libcudnn8=8.6.0+cuda11.4
# LABEL com.nvidia.cudnn.version=8.6.0

# Set environment to noninteractive (this prevents some prompts)
ENV DEBIAN_FRONTEND=noninteractive

# Install some basic utilities and dependencies
RUN apt-get update && apt-get install -y \
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

ENV DEBIAN_FRONTEND=

# create required folder
RUN mkdir -p /app/deepface

# Copy required files from repo into image
COPY ./deepface /app/deepface
COPY ./api/app.py ./api/routes.py ./api/service.py ./requirements.txt ./setup.py ./README.md  /app/

# switch to application directory
WORKDIR /app

# install deepface from source code (always up-to-date)
RUN pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host=files.pythonhosted.org -e .

# environment variables
ENV PYTHONUNBUFFERED=1

# run the app (re-configure port if necessary)
EXPOSE 5000
