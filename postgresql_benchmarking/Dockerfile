# Use the official PostgreSQL 17 image as a base
FROM postgres:17

# Set the working directory to /tpch
WORKDIR /tpch

# Install git, build tools, and dependencies for pgfutter
RUN apt-get update && apt-get install -y git build-essential libpq-dev wget
RUN apt-get install zip -y
COPY tpch_generate.sh tpch_generate.sh
COPY queries /tpch/queries

RUN chmod +x ./tpch_generate.sh 
RUN ./tpch_generate.sh /tpch/.buildstamp /tpch/ 1

# Expose the PostgreSQL port
EXPOSE 5432

# Switch to the postgres user
USER postgres

# Initialize the PostgreSQL database cluster
RUN initdb -D /var/lib/postgresql/data

# Set the listen_addresses parameter to '*'
RUN echo "listen_addresses = '*'" >> /var/lib/postgresql/data/postgresql.conf

# Copy run-tpch.sh script
WORKDIR /tpch
COPY run-tpch.sh /tpch/run-tpch.sh

USER root
RUN mkdir -p /tpch && chown postgres:postgres /tpch
USER postgres

# Run PostgreSQL when the container starts
CMD ["postgres"]
