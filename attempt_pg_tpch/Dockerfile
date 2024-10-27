FROM ubuntu:jammy AS baseimg

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN apt-get update && apt-get install -y software-properties-common wget -y

RUN sed -i '/^# deb-src/s/^# //' /etc/apt/sources.list
RUN apt-get update -y
RUN apt-get build-dep postgresql -y
RUN apt-get install graphviz libreadline-dev zlib1g-dev pgagent libpq5 libxslt1-dev -y


RUN apt-get update && apt-get install -y sudo
RUN useradd -ms /bin/bash myuser
RUN usermod -aG sudo myuser
RUN echo 'myuser ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER myuser
WORKDIR /home/myuser

RUN wget https://ftp.postgresql.org/pub/source/v17.0/postgresql-17.0.tar.gz
RUN tar zxvf postgresql-17.0.tar.gz
WORKDIR /home/myuser/postgresql-17.0
RUN sudo apt-get install libicu-dev -y
RUN sudo apt install pkg-config -y
RUN sudo apt install bison -y
RUN sudo apt install flex -y
RUN CFLAGS="-fno-omit-frame-pointer -rdynamic -O2" ./configure --prefix=/usr/local --enable-debug
RUN make -j$(grep -c ^processor /proc/cpuinfo)
RUN sudo make install
WORKDIR /home/myuser

RUN sudo apt install curl -y
RUN curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg
RUN sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list && apt update'
RUN sudo apt install pgadmin4 -y
WORKDIR /home/myuser

RUN sudo sysctl -w kernel.shmmax=2147483648
RUN sudo sysctl -w kernel.shmall=2097152

RUN cat <<__EOF | sudo tee -a /etc/sysctl.conf
kernel.shmmax=2147483648
kernel.shmall=2097152
__EOF

RUN sudo apt install git -y
RUN git clone https://github.com/2ndQuadrant/pg-tpch.git
WORKDIR pg-tpch
USER root
RUN sudo echo 'myuser ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER myuser
RUN sudo -S ./tpch_prepare


CMD ["sh", "-c", "./tpch_runall_seq"]
