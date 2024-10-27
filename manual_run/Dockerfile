# Use the official PostgreSQL 17 image as a base
FROM postgres:17

# Set the working directory to /tpch
WORKDIR /tpch

# Install git, build tools, and dependencies for pgfutter
RUN apt-get update && apt-get install -y git build-essential libpq-dev wget
RUN apt-get install zip -y
RUN wget https://github.com/osdldbt/dbt3/releases/download/v2.0.10/dbt3-2.0.10-x86_64.AppImage
RUN mv dbt3-2.0.10-x86_64.AppImage dbt3
RUN chmod +x dbt3

COPY TPC-H-Tool.zip .
RUN unzip TPC-H-Tool

# Install FUSE
RUN apt-get install -y fuse libfuse2
RUN groupadd fuse
RUN useradd -G fuse dbt3user


RUN chown -R postgres:postgres /tpch
USER postgres

CMD ["postgres"]
