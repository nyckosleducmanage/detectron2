FROM nvidia/cuda:11.1.1-cudnn8-devel-ubuntu18.04

ENV DEBIAN_FRONTEND noninteractive
ENV CUDA_HOME=/usr/local/cuda
ENV MAX_JOBS=2

RUN apt-get update && apt-get install -y \
    software-properties-common build-essential gcc-7 g++-7 libxrender-dev \
    python3.8 python3.8-dev python3.8-distutils libglib2.0-0 libsm6 libxext6 \
    python3-opencv ca-certificates git wget sudo ninja-build && \
    ln -sf /usr/bin/python3.8 /usr/bin/python3 && \
    ln -sf /usr/bin/python3 /usr/bin/python && \
    wget https://bootstrap.pypa.io/get-pip.py && \
    python3.8 get-pip.py && \
    rm get-pip.py

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 100 && \
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-7 100

ARG USER_ID=1000
RUN useradd -m --no-log-init --system --uid ${USER_ID} appuser -g sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER appuser
WORKDIR /home/appuser

RUN python3.8 -m pip install --user tensorboard cmake onnx
RUN python3.8 -m pip install --user torch==1.10 torchvision==0.11.1 -f https://download.pytorch.org/whl/cu111/torch_stable.html
RUN python3.8 -m pip install --user 'git+https://github.com/facebookresearch/fvcore'

RUN python3.8 -c "import torch; print(torch.cuda.is_available())"

RUN git clone https://github.com/facebookresearch/detectron2 detectron2_repo

ENV FORCE_CUDA="1"
ENV TORCH_CUDA_ARCH_LIST="Turing;Ampere"

RUN python3.8 -m pip install -v --user -e detectron2_repo

ENV FVCORE_CACHE="/tmp"
WORKDIR /home/appuser/detectron2_repo
