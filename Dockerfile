# Copyright (c) 2020, NVIDIA CORPORATION.  All rights reserved.
#
# NVIDIA CORPORATION and its licensors retain all intellectual property
# and proprietary rights in and to this software, related documentation
# and any modifications thereto.  Any use, reproduction, disclosure or
# distribution of this software and related documentation without an express
# license agreement from NVIDIA CORPORATION is strictly prohibited.

# Note: Should also work with NVIDIA's Docker image builds such as
#
#ARG BASE_IMAGE=nvcr.io/nvidia/pytorch:20.09-py3
#
# This file defaults to pytorch/pytorch as it works on slightly older
# driver versions.
ARG BASE_IMAGE=pytorch/pytorch:1.7.1-cuda11.0-cudnn8-devel
FROM $BASE_IMAGE

RUN apt-get update && apt-get install -y --no-install-recommends \
    pkg-config \
    libglvnd0 \
    libgl1 \
    libglx0 \
    libegl1 \
    libgles2 \
    libglvnd-dev \
    libgl1-mesa-dev \
    libegl1-mesa-dev \
    libgles2-mesa-dev \
    cmake \
    curl \ 
    libsm6 \
    libxext6 \
    libxrender-dev

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# for GLEW
ENV LD_LIBRARY_PATH /usr/lib64:$LD_LIBRARY_PATH

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility,graphics

# Default pyopengl to EGL for good headless rendering support
ENV PYOPENGL_PLATFORM egl

COPY docker/10_nvidia.json /usr/share/glvnd/egl_vendor.d/10_nvidia.json

RUN pip install imageio imageio-ffmpeg

COPY nvdiffrast/nvdiffrast /tmp/pip/nvdiffrast/
COPY nvdiffrast/README.md nvdiffrast/setup.py /tmp/pip/
RUN cd /tmp/pip && pip install .
COPY requirement.txt requirement.txt
RUN pip install -r requirement.txt