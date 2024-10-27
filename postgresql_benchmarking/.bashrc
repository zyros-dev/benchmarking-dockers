# Use the official PostgreSQL 17 image as a base
FROM postgres:17

# Set the working directory to /tpch
WORKDIR /tpch

# Copy the TPC-H-Tool.zip file from the current directory
COPY TPC-H-Tool.zip .

# Unzip the TPC-H-Tool.zip file
RUN unzip TPC-H-Tool.zip

# Set environment variables for dbgen
ENV PATH=$PATH:/tpch/dbgen
ENV DSS_PATH=/tpch/dbgen

# Generate TPC-H data with scale factor 1
RUN dbgen -s 1

# Generate TPC-H data with scale factor 10
RUN dbgen -s 10

# Create a PostgreSQL database and user for TPC-H
RUN psql -U postgres -c "CREATE DATABASE tpch;"
RUN psql -U postgres -c "CREATE ROLE tpch WITH PASSWORD 'tpch';"
RUN psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE tpch TO tpch;"

# Load TPC-H data into PostgreSQL with scale factor 1
RUN pg_ctl start
RUN psql -U tpch -d tpch -c "LOAD 'sf1/lineitem.tbl' INTO lineitem;"
RUN psql -U tpch -d tpch -c "LOAD 'sf1/orders.tbl' INTO orders;"
RUN psql -U tpch -d tpch -c "LOAD 'sf1/customer.tbl' INTO customer;"
RUN psql -U tpch -d tpch -c "LOAD 'sf1/nation.tbl' INTO nation;"
RUN psql -U tpch -d tpch -c "LOAD 'sf1/region.tbl' INTO region;"
RUN psql -U tpch -d tpch -c "LOAD 'sf1/part.tbl' INTO part;"
RUN psql -U tpch -d tpch -c "LOAD 'sf1/partsupp.tbl' INTO partsupp;"
RUN psql -U tpch -d tpch -c "LOAD 'sf1/supplier.tbl' INTO supplier;"

# Run TPC-H benchmark with scale factor 1
RUN pg_ctl start
RUN psql -U tpch -d tpch -c "EXPLAIN (ANALYZE, VERBOSE) SELECT * FROM lineitem WHERE l_orderkey < 100;"
RUN psql -U tpch -d tpch -c "EXPLAIN (ANALYZE, VERBOSE) SELECT * FROM orders WHERE o_orderkey < 100;"
RUN psql -U tpch -d tpch -c "EXPLAIN (ANALYZE, VERBOSE) SELECT * FROM customer WHERE c_custkey < 100;"

# Save results to a file
RUN psql -U tpch -d tpch -c "EXPLAIN (ANALYZE, VERBOSE) SELECT * FROM lineitem WHERE l_orderkey < 100;" >results_sf1.txt
RUN psql -U tpch -d tpch -c "EXPLAIN (ANALYZE, VERBOSE) SELECT * FROM orders WHERE o_orderkey < 100;" >>results_sf1.txt
RUN psql -U tpch -d tpch -c "EXPLAIN (ANALYZE, VERBOSE) SELECT * FROM customer WHERE c_custkey < 100;" >>results_sf1.txt

# Load TPC-H data into PostgreSQL with scale factor 10
RUN pg_ctl start
RUN psql -U tpch -d tpch -c "LOAD 'sf10/lineitem.tbl' INTO lineitem;"
RUN psql -U tpch -d tpch -c "LOAD 'sf10/orders.tbl' INTO orders;"
RUN psql -U tpch -d tpch -c "LOAD 'sf10/customer.tbl' INTO customer;"
RUN psql -U tpch -d tpch -c "LOAD 'sf10/nation.tbl' INTO nation;"
RUN psql -U tpch -d tpch -c "LOAD 'sf10/region.tbl' INTO region;"
RUN psql -U tpch -d tpch -c "LOAD 'sf10/part.tbl' INTO part;"
RUN psql -U tpch -d tpch -c "LOAD 'sf10/partsupp.tbl' INTO partsupp;"
RUN psql -U tpch -d tpch -c "LOAD 'sf10/supplier.tbl' INTO supplier;"

# Run TPC-H benchmark with scale factor 10
RUN pg_ctl start
RUN psql -U tpch -d tpch -c "EXPLAIN (ANALYZE, VERBOSE) SELECT * FROM lineitem WHERE l_orderkey < 1000;"
RUN
