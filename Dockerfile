FROM nvidia/cuda:11.8.0-devel-ubuntu22.04
SHELL ["/bin/bash", "-c"]

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
    curl \
    wget \
    libmkl-full-dev \
    gcc-10 \
    g++-10 \
    python3 \
    python3-pip \
    python3-dev
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p /opt/conda && \
    rm /tmp/miniconda.sh

RUN echo "source /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc
RUN echo "conda activate" >> ~/.bashrc
RUN /opt/conda/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
RUN /opt/conda/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
RUN /opt/conda/bin/conda install python=3.10
SHELL ["/opt/conda/bin/conda", "run", "-n", "base", "bash", "-c"]

RUN pip install "numpy<2.0" torch==2.4.1 torchvision==0.19.1 torchaudio==2.4.1 --index-url https://download.pytorch.org/whl/cu118
ARG TORCH_CUDA_ARCH_LIST="8.9"

RUN pip install git+https://github.com/jeffrey-ke/gsplat.git
RUN curl https://raw.githubusercontent.com/jeffrey-ke/digital-replica/main/examples/requirements.txt | pip install -r /dev/stdin
# I suspect that pip's global dependency resolver is detecting that these two following vcs packages have incompatible versions
RUN pip install git+https://github.com/nerfstudio-project/nerfview@4538024fe0d15fd1a0e4d760f3695fc44ca72787

WORKDIR /home
RUN git clone https://github.com/rmbrualla/pycolmap && \
    cd pycolmap && \
    git checkout cc7ea4b7301720ac29287dbe450952511b32125e && \
    pip install .

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
