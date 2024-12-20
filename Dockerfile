FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV OPENCV_VERSION=pcl-1.10.0
ENV OPENCV_INSTALL_DIR=

# Update and install required packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    ca-certificates \
    cmake \
    sudo \
    curl \
    clang-format \
    gdb

WORKDIR /opt

# OpenCV dependencies

# Install required packages
RUN apt-get install -y --no-install-recommends \
    pkg-config \
    libgtk2.0-dev

RUN git clone -b 4.10.0 https://github.com/opencv/opencv.git && \
    git clone -b 4.10.0 https://github.com/opencv/opencv_contrib.git

# Build
RUN cd opencv && \
    cmake -S . -B build \
        -DOPENCV_EXTRA_MODULES_PATH=../opencv_contrib/modules \
        -DCMAKE_BUILD_TYPE=Release && \
    cmake --build build && \
    cmake --install build 
    # && \
    # cd .. && rm -rf opencv opencv_contrib

# Clean up to keep the image size small
RUN apt clean && \
    rm -rf /var/lib/apt/lists/*

# Create a new user 'user' with sudo privileges
RUN useradd -m user && \
    echo "user ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/user && \
    chmod 0440 /etc/sudoers.d/user

# Use sed to uncomment the force_color_prompt line in ~/.bashrc
RUN sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/user/.bashrc

# Switch to the 'user' you created
USER user

WORKDIR /home/user

# Default command
CMD ["/bin/bash"]
