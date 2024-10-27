#!/bin/bash

# Drop existing database
psql -U postgres -c "DROP DATABASE IF EXISTS tpch;"

# Drop existing role
psql -U postgres -c "DROP ROLE IF EXISTS tpch;"

# Create the tpch database
psql -U postgres -c "CREATE DATABASE tpch;"

# Create the tpch role with login privileges
psql -U postgres -c "CREATE ROLE tpch WITH PASSWORD 'tpch' LOGIN;"

# Grant privileges to the tpch role
psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE tpch TO tpch;"
psql -U postgres -c "GRANT ALL PRIVILEGES ON SCHEMA public TO tpch;"

psql -U postgres -c "GRANT pg_read_server_files TO tpch;"

# Set tpch user as owner of tpch database
psql -U postgres -c "ALTER DATABASE tpch OWNER TO tpch;"

psql -U tpch -d tpch -c "\i /tpch/queries/initialize.sql"

# Load TPC-H data into PostgreSQL with scale factor 1
psql -U tpch -d tpch -c "\copy lineitem FROM '/tpch/lineitem.tbl' DELIMITER '|' CSV;"
psql -U tpch -d tpch -c "\copy orders FROM '/tpch/orders.tbl' DELIMITER '|' CSV;"
psql -U tpch -d tpch -c "\copy customer FROM '/tpch/customer.tbl' DELIMITER '|' CSV;"
psql -U tpch -d tpch -c "\copy nation FROM '/tpch/nation.tbl' DELIMITER '|' CSV;"
psql -U tpch -d tpch -c "\copy region FROM '/tpch/region.tbl' DELIMITER '|' CSV;"
psql -U tpch -d tpch -c "\copy part FROM '/tpch/part.tbl' DELIMITER '|' CSV;"
psql -U tpch -d tpch -c "\copy partsupp FROM '/tpch/partsupp.tbl' DELIMITER '|' CSV;"
psql -U tpch -d tpch -c "\copy supplier FROM '/tpch/supplier.tbl' DELIMITER '|' CSV;"

# Run TPC-H benchmark with scale factor 1
psql -U tpch -d tpch -c "EXPLAIN (ANALYZE, VERBOSE) SELECT * FROM lineitem WHERE l_orderkey < 100;" >/tmp/results.txt
psql -U tpch -d tpch -c "EXPLAIN (ANALYZE, VERBOSE) SELECT * FROM orders WHERE o_orderkey < 100;" >>/tmp/results.txt
psql -U tpch -d tpch -c "EXPLAIN (ANALYZE, VERBOSE) SELECT * FROM customer WHERE c_custkey < 100;" >>/tmp/results.txt

# Change ownership of results file
chmod 644 /tmp/results.txt
