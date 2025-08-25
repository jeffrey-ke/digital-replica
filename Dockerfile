FROM nvidia/cuda:11.8.0-devel-ubuntu22.04

ARG DEBIAN_FRONTEND=noninteractive


# update apt
RUN  apt-get update

# apt-get all the shit
RUN  apt-get install -y \
    git \
    cmake \
    ninja-build \
    build-essential \
    libboost-program-options-dev \
    libboost-graph-dev \
    libboost-system-dev \
    libeigen3-dev \
    libfreeimage-dev \
    libmetis-dev \
    libgoogle-glog-dev \
    libgtest-dev \
    libgmock-dev \
    libsqlite3-dev \
    libglew-dev \
    qtbase5-dev \
    libqt5opengl5-dev \
    libcgal-dev \
    libceres-dev \
    libcurl4-openssl-dev \
    libmkl-full-dev \
    gcc-10 \
    g++-10 \
    python3 \
    python3-pip \
    python3-dev
RUN pip install torch==2.4.1 torchvision==0.19.1 torchaudio==2.4.1 --index-url https://download.pytorch.org/whl/cu118
RUN pip install "numpy<2.0"
ARG TORCH_CUDA_ARCH_LIST="8.9"

RUN pip install git+https://github.com/jeffrey-ke/gsplat.git
RUN pip install -r <(curl -s https://raw.githubusercontent.com/nerfstudio-project/gsplat/65042cc501d1cdbefaf1d6f61a9a47575eec8c71/examples/requirements.txt)

# for compiling against gcc 10 as per colmap instructions
ENV CC=/usr/bin/gcc-10
ENV CXX=/usr/bin/g++-10
ENV CUDAHOSTCXX=/usr/bin/g++-10

# actually build colmap
WORKDIR /home/colmap
RUN git clone https://github.com/colmap/colmap.git . && \
    mkdir build && \
    cd build && \
    cmake .. -GNinja -DBLA_VENDOR=Intel10_64lp -DCMAKE_CUDA_ARCHITECTURES=89&& \
    ninja && \
    ninja install
WORKDIR /home
