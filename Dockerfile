# syntax=docker/dockerfile:1

#
# This file is part of Grafite <https://github.com/marcocosta97/grafite>.
# Copyright (C) 2023 Marco Costa.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

# Use a base image with a 64-bit Linux distribution
FROM ubuntu:20.04

LABEL maintainer="mcosta97@pm.me"
LABEL version="1.0"
LABEL description="This is custom Docker Image for the reproducibility of the \
    experimental evaluation published in the Grafite paper by Costa et al. at \
    SIGMOD 2024."

# Set environment variables to non-interactive to avoid prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Update the package list and install necessary packages
RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean \ 
    && apt-get update && apt-get --no-install-recommends install -y \
    bc \
    build-essential \
    cmake \
    cm-super \
    coreutils \
    dvipng \
    git \
    g++ \
    libboost-all-dev \
    lz4 \
    python3 \
    python3-pip \
    texlive-full \
    unzip \
    wget \
    zstd 

# Create a working directory
WORKDIR /app

# Copy the project files into the working directory
COPY reproduce.sh .

# Autostart the script
CMD ["bash", "reproduce.sh"]
