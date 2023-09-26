#base image
FROM nvidia/cuda:11.0-base-ubuntu20.04

# Install some basic utilities and dependencies
RUN apt-get update && apt-get install -y \
  wget \
  build-essential \
  libsm6 \
  libxext6 \
  libxrender-dev \
  libglib2.0-0 \
  && rm -rf /var/lib/apt/lists/*

# Install Python and pip
RUN apt-get update && apt-get install -y \
  python3.8 \
  python3-pip \
  && rm -rf /var/lib/apt/lists/*

# Upgrade pip
RUN pip3 install --upgrade pip

# Install TensorFlow GPU version
RUN pip3 install tensorflow-gpu==2.5

# create required folder
RUN mkdir /app
RUN mkdir /app/deepface

# Copy required files from repo into image
COPY ./deepface /app/deepface
COPY ./api/app.py /app/
COPY ./api/routes.py /app/
COPY ./api/service.py /app/
COPY ./requirements.txt /app/
COPY ./setup.py /app/

# switch to application directory
WORKDIR /app

# install deepface from source code (always up-to-date)
RUN pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host=files.pythonhosted.org -e .

# environment variables
ENV PYTHONUNBUFFERED=1

# run the app (re-configure port if necessary)
EXPOSE 5000
