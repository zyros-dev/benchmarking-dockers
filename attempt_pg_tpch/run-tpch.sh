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

echo "pgfutter time!"
export PGHOST=localhost
export PGUSER=tpch
export PGPASSWORD=tpch
export PGDATABASE=tpch
export PGPORT=5432

# Create tables using pgfutter
cd /tpch
pgfutter csv --delimiter "|" lineitem.tbl
pgfutter csv --delimiter "|" orders.tbl
pgfutter csv --delimiter "|" customer.tbl
pgfutter csv --delimiter "|" nation.tbl
pgfutter csv --delimiter "|" region.tbl
pgfutter csv --delimiter "|" part.tbl
pgfutter csv --delimiter "|" partsupp.tbl
pgfutter csv --delimiter "|" supplier.tbl

# Load TPC-H data into PostgreSQL with scale factor 1
psql -U tpch -d tpch -c "\copy lineitem FROM 'lineitem.tbl' DELIMITER '|' CSV;"
psql -U tpch -d tpch -c "\copy orders FROM 'orders.tbl' DELIMITER '|' CSV;"
psql -U tpch -d tpch -c "\copy customer FROM 'customer.tbl' DELIMITER '|' CSV;"
psql -U tpch -d tpch -c "\copy nation FROM 'nation.tbl' DELIMITER '|' CSV;"
psql -U tpch -d tpch -c "\copy region FROM 'region.tbl' DELIMITER '|' CSV;"
psql -U tpch -d tpch -c "\copy part FROM 'part.tbl' DELIMITER '|' CSV;"
psql -U tpch -d tpch -c "\copy partsupp FROM 'partsupp.tbl' DELIMITER '|' CSV;"
psql -U tpch -d tpch -c "\copy supplier FROM 'supplier.tbl' DELIMITER '|' CSV;"

# Run TPC-H benchmark with scale factor 1
psql -U tpch -d tpch -c "EXPLAIN (ANALYZE, VERBOSE) SELECT * FROM lineitem WHERE l_orderkey < 100;" >/tpch/results_sf1.txt
psql -U tpch -d tpch -c "EXPLAIN (ANALYZE, VERBOSE) SELECT * FROM orders WHERE o_orderkey < 100;" >>/tpch/results_sf1.txt
psql -U tpch -d tpch -c "EXPLAIN (ANALYZE, VERBOSE) SELECT * FROM customer WHERE c_custkey < 100;" >>/tpch/results_sf1.txt

# Change ownership of results file
chmod 644 /tpch/results_sf1.txt
