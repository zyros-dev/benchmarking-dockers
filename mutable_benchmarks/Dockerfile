FROM ubuntu:jammy AS baseimg

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

ENV DEBIAN_FRONTEND=noninteractive


RUN apt-get update

RUN apt-get update && \
    apt-get install -y \
    software-properties-common \
    build-essential \
    git wget \
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

RUN wget https://apt.llvm.org/llvm.sh
RUN chmod +x llvm.sh
RUN ./llvm.sh 16
RUN ln -s /usr/bin/clang-16 /usr/bin/clang \
    && ln -s /usr/bin/clang++-16 /usr/bin/clang++

# ---------------------------------------------------------------------------------

RUN mkdir /output
RUN git clone https://github.com/mutable-org/mutable
WORKDIR /mutable

WORKDIR /
RUN git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
RUN export PATH=/depot_tools:$PATH 

RUN alias python=python3
RUN git clone https://gn.googlesource.com/gn
WORKDIR /gn
RUN python3 build/gen.py
RUN ninja -C out
RUN cp out/gn /usr/local/bin
# manually install cmake... this takes very long so let's try something else...
# WORKDIR /
# RUN wget https://github.com/Kitware/CMake/releases/download/v3.30.5/cmake-3.30.5.tar.gz
# RUN tar -xzvf cmake-3.30.5.tar.gz
# WORKDIR /cmake-3.30.5
# RUN apt install openssl -y libssl-dev
# RUN ./configure
# RUN make
# RUN make install

WORKDIR /
RUN apt remove -y cmake 
RUN wget https://github.com/Kitware/CMake/releases/download/v3.30.5/cmake-3.30.5-linux-x86_64.sh
RUN cp cmake-3.30.5-linux-x86_64.sh /opt/
WORKDIR /opt/
RUN chmod +x cmake-3.30.5-linux-x86_64.sh 
RUN bash cmake-3.30.5-linux-x86_64.sh --skip-license
RUN ln -sf /opt/bin/* /usr/local/bin/

WORKDIR /mutable
RUN mkdir build
RUN mkdir build/release
RUN cmake -S . -B build/release \
  -G Ninja \
  -DCMAKE_C_COMPILER=clang \
  -DCMAKE_CXX_COMPILER=clang++ \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=OFF \
  -DENABLE_SANITIZERS=ON \
  -DENABLE_SANITY_FIELDS=ON \
  -DWITH_V8=ON
RUN cmake --build build/release

# everything above this takes long so don't edit there
# ---------------------------------------------------------------------------------

WORKDIR / 
RUN wget https://github.com/duckdb/duckdb/releases/download/v1.1.2/duckdb_cli-linux-amd64.zip
RUN apt-get install -y zip
RUN unzip duckdb_cli-linux-amd64.zip
RUN cp duckdb /mutable/benchmark/database_connectors/

# install postgresql

RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
RUN apt update -y
RUN apt install -y postgresql-17
RUN systemctl enable postgresql

RUN mkdir -p /var/lib/postgresql/data && chown -R postgres:postgres /var/lib/postgresql
USER postgres
RUN /usr/lib/postgresql/17/bin/initdb -D /var/lib/postgresql/data
RUN echo "listen_addresses='*'" >> /var/lib/postgresql/data/postgresql.conf

USER root

WORKDIR /mutable
RUN apt install -y pipenv
RUN pip install --upgrade pipenv
RUN pipenv --clear
RUN apt-get install -y graphviz graphviz-dev
RUN pipenv run pip install --global-option=build_ext \
                       --global-option="-I/usr/include/graphviz" \
                       --global-option="-L/usr/lib/graphviz" \
                       pygraphviz
RUN apt-get install -y libpq-dev
RUN pipenv install



# CMD ["/usr/lib/postgresql/17/bin/pg_ctl", "-D", "/var/lib/postgresql/data", "-l", "/var/lib/postgresql/data/logfile", "start"]
CMD ["tail", "-f", "/dev/null"]

