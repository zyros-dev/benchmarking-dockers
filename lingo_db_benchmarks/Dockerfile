FROM ubuntu:jammy AS baseimg

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

ENV DEBIAN_FRONTEND=noninteractive


RUN apt-get update
RUN apt-get -y install python3 python3-venv git cmake  g++ ninja-build wget unzip ccache curl lsb-release wget zlib1g-dev lcov
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:$PATH"
RUN cargo install --force cbindgen

RUN apt-get update && \
    apt-get install -y \
    software-properties-common \
    build-essential \
    git \
    cmake \
    libboost-all-dev \
    libsqlite3-dev \
    libxml2-dev \
    libxslt-dev \
    curl \
    ninja-build \
    && add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y python3.10 python3.10-distutils python3.10-venv && \
    apt-get clean && \
    rm -rf /var/lib/at/lists/*

RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10
RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install virtualenv

RUN mkdir /output
RUN git clone https://github.com/lingo-db/lingo-db.git
COPY Makefile /lingo-db/
WORKDIR /lingo-db

RUN echo "-f https://www.lingo-db.com/dev-dependencies/" > requirements.txt && \
    echo "lingodb-llvm==0.0.0.dev0" >> requirements.txt && \
    echo "numpy==1.26.4" >> requirements.txt && \
    echo "pyarrow==14.0.0" >> requirements.txt && \
    echo "lit==17.0.5" >> requirements.txt && \
    echo "tbb-devel==2021.11.0" >> requirements.txt && \
    echo "setuptools" >> requirements.txt

RUN apt-get update && apt-get install -y llvm

RUN python3 -m pip install -r requirements.txt

CMD ["sh", "-c", "make run-benchmark"]