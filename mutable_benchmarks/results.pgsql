CREATE OR REPLACE FUNCTION insert_suite(text)
RETURNS void
LANGUAGE SQL
AS $func$
    INSERT INTO "Suites" (name)
    SELECT $1
    WHERE NOT $1 IN (SELECT name FROM "Suites")
$func$;

CREATE OR REPLACE FUNCTION insert_benchmark(int, text)
RETURNS void
LANGUAGE SQL
AS $func$
    INSERT INTO "Benchmarks" (suite, name)
    SELECT $1, $2
    WHERE NOT ($1, $2) IN (SELECT suite, name FROM "Benchmarks");
$func$;

CREATE OR REPLACE FUNCTION insert_configuration(text, text)
RETURNS void
LANGUAGE SQL
AS $func$
    INSERT INTO "Configurations" (name, parameters)
    SELECT $1, $2
    WHERE NOT ($1, $2) IN (SELECT name, parameters FROM "Configurations");
$func$;

CREATE OR REPLACE FUNCTION insert_timestamp(text, timestamptz, text)
RETURNS void
LANGUAGE SQL
AS $func$
    INSERT INTO "Timestamps" ("commit", "timestamp", "host")
    SELECT $1, $2, $3
    WHERE NOT ($2, $3) IN (SELECT timestamp, host FROM "Timestamps");
$func$;

CREATE OR REPLACE FUNCTION insert_experiment(int, text, int, text, bool, int)
RETURNS void
LANGUAGE SQL
AS $func$
    INSERT INTO "Experiments" (benchmark, name, version, description, is_read_only, chart_config)
    SELECT $1, $2, $3, $4, $5, $6
    WHERE NOT ($1, $2, $3) IN (SELECT benchmark, name, version FROM "Experiments");
$func$;

CREATE OR REPLACE FUNCTION insert_chartconfig(text, text, text, text, text, text)
RETURNS void
LANGUAGE SQL
AS $func$
    INSERT INTO "ChartConfig" (scale_x, scale_y, type_x, type_y, label_x, label_y)
    SELECT $1, $2, $3, $4, $5, $6
    WHERE NOT ($1, $2, $3, $4, $5, $6) IN (SELECT scale_x, scale_y, type_x, type_y, label_x, label_y FROM "ChartConfig");
$func$;

DO $$
DECLARE
    timestamp_id integer;
    suite_id integer;
    benchmark_id integer;
    experiment_id integer;
    configuration_id integer;
    chartconfig_id integer;
BEGIN
    -- Get timestamp
    PERFORM insert_timestamp('a2b1bd45750ebc13a41ba169d377547cc54bc4f8', '2024-11-03 08:13:34', 'fa452b623e50');
    SELECT id FROM "Timestamps"
    WHERE "commit"='a2b1bd45750ebc13a41ba169d377547cc54bc4f8'
      AND "timestamp"='2024-11-03 08:13:34'
      AND "host"='fa452b623e50'
    INTO timestamp_id;

    -- Get suite
    PERFORM insert_suite('TPC');
    SELECT id FROM "Suites"
    WHERE name='TPC'
    INTO suite_id;

    -- Get benchmark
    PERFORM insert_benchmark(suite_id, 'TPC-H Compilation Times');
    SELECT id FROM "Benchmarks"
    WHERE suite=suite_id
      AND name='TPC-H Compilation Times'
    INTO benchmark_id;

    -- Get chart configuration
    PERFORM insert_chartconfig('linear', 'linear', 'O', 'Q', 'Scale factor', 'Compilation time [ms]');
    SELECT id FROM "ChartConfig"
    WHERE scale_x='linear' AND scale_y='linear'
      AND type_x='O' AND type_y='Q'
      AND label_x='Scale factor' AND label_y='Compilation time [ms]'
    INTO chartconfig_id;

    -- Get experiment
    PERFORM insert_experiment(benchmark_id, 'Q12', 1, 'TPC-H Query 12', TRUE, chartconfig_id);
    SELECT id FROM "Experiments"
    WHERE benchmark=benchmark_id
      AND name='Q12'
      AND version=1
    INTO experiment_id;

    -- Update chartconfig of this experiment (if a new one was inserted)
    UPDATE "Experiments"
    SET chart_config=chartconfig_id
    WHERE id=experiment_id;

    -- Get config
    PERFORM insert_configuration('mutable (single core, WasmV8, PAX4M)', 'Execution Time');
    SELECT id FROM "Configurations"
    WHERE name='mutable (single core, WasmV8, PAX4M)'
      AND parameters='Execution Time'
    INTO configuration_id;

    -- Write measurements
    --  timestamp:  ('a2b1bd45750ebc13a41ba169d377547cc54bc4f8', '2024-11-03 08:13:34', 'fa452b623e50')
    --  suite:      'TPC'
    --  benchmark:  'TPC-H Compilation Times'
    --  experiment: 'Q12'
    --  config:     'mutable (single core, WasmV8, PAX4M)'
    INSERT INTO "Measurements" ("timestamp", "experiment", "config", "case", "value", "run_id")
    VALUES
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 0),
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 1),
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 2),
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 3),
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 4);

    -- Get chart configuration
    PERFORM insert_chartconfig('linear', 'linear', 'O', 'Q', 'Scale factor', 'Compilation time [ms]');
    SELECT id FROM "ChartConfig"
    WHERE scale_x='linear' AND scale_y='linear'
      AND type_x='O' AND type_y='Q'
      AND label_x='Scale factor' AND label_y='Compilation time [ms]'
    INTO chartconfig_id;

    -- Get experiment
    PERFORM insert_experiment(benchmark_id, 'Q14', 1, 'TPC-H Query 14', TRUE, chartconfig_id);
    SELECT id FROM "Experiments"
    WHERE benchmark=benchmark_id
      AND name='Q14'
      AND version=1
    INTO experiment_id;

    -- Update chartconfig of this experiment (if a new one was inserted)
    UPDATE "Experiments"
    SET chart_config=chartconfig_id
    WHERE id=experiment_id;

    -- Get config
    PERFORM insert_configuration('mutable (single core, WasmV8, PAX4M)', 'Execution Time');
    SELECT id FROM "Configurations"
    WHERE name='mutable (single core, WasmV8, PAX4M)'
      AND parameters='Execution Time'
    INTO configuration_id;

    -- Write measurements
    --  timestamp:  ('a2b1bd45750ebc13a41ba169d377547cc54bc4f8', '2024-11-03 08:13:34', 'fa452b623e50')
    --  suite:      'TPC'
    --  benchmark:  'TPC-H Compilation Times'
    --  experiment: 'Q14'
    --  config:     'mutable (single core, WasmV8, PAX4M)'
    INSERT INTO "Measurements" ("timestamp", "experiment", "config", "case", "value", "run_id")
    VALUES
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 0),
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 1),
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 2),
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 3),
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 4);

    -- Get chart configuration
    PERFORM insert_chartconfig('linear', 'linear', 'O', 'Q', 'Scale factor', 'Compilation time [ms]');
    SELECT id FROM "ChartConfig"
    WHERE scale_x='linear' AND scale_y='linear'
      AND type_x='O' AND type_y='Q'
      AND label_x='Scale factor' AND label_y='Compilation time [ms]'
    INTO chartconfig_id;

    -- Get experiment
    PERFORM insert_experiment(benchmark_id, 'Q3', 1, 'Compile TPC-H Query 3', TRUE, chartconfig_id);
    SELECT id FROM "Experiments"
    WHERE benchmark=benchmark_id
      AND name='Q3'
      AND version=1
    INTO experiment_id;

    -- Update chartconfig of this experiment (if a new one was inserted)
    UPDATE "Experiments"
    SET chart_config=chartconfig_id
    WHERE id=experiment_id;

    -- Get config
    PERFORM insert_configuration('mutable (single core, WasmV8, PAX4M)', 'Execution Time');
    SELECT id FROM "Configurations"
    WHERE name='mutable (single core, WasmV8, PAX4M)'
      AND parameters='Execution Time'
    INTO configuration_id;

    -- Write measurements
    --  timestamp:  ('a2b1bd45750ebc13a41ba169d377547cc54bc4f8', '2024-11-03 08:13:34', 'fa452b623e50')
    --  suite:      'TPC'
    --  benchmark:  'TPC-H Compilation Times'
    --  experiment: 'Q3'
    --  config:     'mutable (single core, WasmV8, PAX4M)'
    INSERT INTO "Measurements" ("timestamp", "experiment", "config", "case", "value", "run_id")
    VALUES
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 0),
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 1),
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 2),
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 3),
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 4);

    -- Get chart configuration
    PERFORM insert_chartconfig('linear', 'linear', 'O', 'Q', 'Scale factor', 'Compilation time [ms]');
    SELECT id FROM "ChartConfig"
    WHERE scale_x='linear' AND scale_y='linear'
      AND type_x='O' AND type_y='Q'
      AND label_x='Scale factor' AND label_y='Compilation time [ms]'
    INTO chartconfig_id;

    -- Get experiment
    PERFORM insert_experiment(benchmark_id, 'Q6', 1, 'TPC-H Query 6', TRUE, chartconfig_id);
    SELECT id FROM "Experiments"
    WHERE benchmark=benchmark_id
      AND name='Q6'
      AND version=1
    INTO experiment_id;

    -- Update chartconfig of this experiment (if a new one was inserted)
    UPDATE "Experiments"
    SET chart_config=chartconfig_id
    WHERE id=experiment_id;

    -- Get config
    PERFORM insert_configuration('mutable (single core, WasmV8, PAX4M)', 'Execution Time');
    SELECT id FROM "Configurations"
    WHERE name='mutable (single core, WasmV8, PAX4M)'
      AND parameters='Execution Time'
    INTO configuration_id;

    -- Write measurements
    --  timestamp:  ('a2b1bd45750ebc13a41ba169d377547cc54bc4f8', '2024-11-03 08:13:34', 'fa452b623e50')
    --  suite:      'TPC'
    --  benchmark:  'TPC-H Compilation Times'
    --  experiment: 'Q6'
    --  config:     'mutable (single core, WasmV8, PAX4M)'
    INSERT INTO "Measurements" ("timestamp", "experiment", "config", "case", "value", "run_id")
    VALUES
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 0),
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 1),
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 2),
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 3),
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 4);

    -- Get benchmark
    PERFORM insert_benchmark(suite_id, 'TPC-H');
    SELECT id FROM "Benchmarks"
    WHERE suite=suite_id
      AND name='TPC-H'
    INTO benchmark_id;

    -- Get chart configuration
    PERFORM insert_chartconfig('linear', 'linear', 'O', 'Q', 'Scale factor', 'Execution time [ms]');
    SELECT id FROM "ChartConfig"
    WHERE scale_x='linear' AND scale_y='linear'
      AND type_x='O' AND type_y='Q'
      AND label_x='Scale factor' AND label_y='Execution time [ms]'
    INTO chartconfig_id;

    -- Get experiment
    PERFORM insert_experiment(benchmark_id, 'Q1', 1, 'TPC-H Query 1', TRUE, chartconfig_id);
    SELECT id FROM "Experiments"
    WHERE benchmark=benchmark_id
      AND name='Q1'
      AND version=1
    INTO experiment_id;

    -- Update chartconfig of this experiment (if a new one was inserted)
    UPDATE "Experiments"
    SET chart_config=chartconfig_id
    WHERE id=experiment_id;

    -- Get config
    PERFORM insert_configuration('mutable (single core, WasmV8, PAX4M)', 'Execution Time');
    SELECT id FROM "Configurations"
    WHERE name='mutable (single core, WasmV8, PAX4M)'
      AND parameters='Execution Time'
    INTO configuration_id;

    -- Write measurements
    --  timestamp:  ('a2b1bd45750ebc13a41ba169d377547cc54bc4f8', '2024-11-03 08:13:34', 'fa452b623e50')
    --  suite:      'TPC'
    --  benchmark:  'TPC-H'
    --  experiment: 'Q1'
    --  config:     'mutable (single core, WasmV8, PAX4M)'
    INSERT INTO "Measurements" ("timestamp", "experiment", "config", "case", "value", "run_id")
    VALUES
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 0),
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 1),
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 2),
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 3),
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 4);

    -- Get config
    PERFORM insert_configuration('PostgreSQL', 'Execution Time');
    SELECT id FROM "Configurations"
    WHERE name='PostgreSQL'
      AND parameters='Execution Time'
    INTO configuration_id;

    -- Write measurements
    --  timestamp:  ('a2b1bd45750ebc13a41ba169d377547cc54bc4f8', '2024-11-03 08:13:34', 'fa452b623e50')
    --  suite:      'TPC'
    --  benchmark:  'TPC-H'
    --  experiment: 'Q1'
    --  config:     'PostgreSQL'
    INSERT INTO "Measurements" ("timestamp", "experiment", "config", "case", "value", "run_id")
    VALUES
        (timestamp_id, experiment_id, configuration_id, 1, 6317.124, 0),
        (timestamp_id, experiment_id, configuration_id, 1, 7474.04, 1),
        (timestamp_id, experiment_id, configuration_id, 1, 5867.109, 2),
        (timestamp_id, experiment_id, configuration_id, 1, 7367.299, 3),
        (timestamp_id, experiment_id, configuration_id, 1, 5434.448, 4);

    -- Get config
    PERFORM insert_configuration('DuckDB (single core)', 'Execution Time');
    SELECT id FROM "Configurations"
    WHERE name='DuckDB (single core)'
      AND parameters='Execution Time'
    INTO configuration_id;

    -- Write measurements
    --  timestamp:  ('a2b1bd45750ebc13a41ba169d377547cc54bc4f8', '2024-11-03 08:13:34', 'fa452b623e50')
    --  suite:      'TPC'
    --  benchmark:  'TPC-H'
    --  experiment: 'Q1'
    --  config:     'DuckDB (single core)'
    INSERT INTO "Measurements" ("timestamp", "experiment", "config", "case", "value", "run_id")
    VALUES
        (timestamp_id, experiment_id, configuration_id, 1, 251.0, 0),
        (timestamp_id, experiment_id, configuration_id, 1, 271.0, 1),
        (timestamp_id, experiment_id, configuration_id, 1, 239.0, 2),
        (timestamp_id, experiment_id, configuration_id, 1, 246.0, 3),
        (timestamp_id, experiment_id, configuration_id, 1, 243.0, 4);

    -- Get config
    PERFORM insert_configuration('DuckDB (4 cores)', 'Execution Time');
    SELECT id FROM "Configurations"
    WHERE name='DuckDB (4 cores)'
      AND parameters='Execution Time'
    INTO configuration_id;

    -- Write measurements
    --  timestamp:  ('a2b1bd45750ebc13a41ba169d377547cc54bc4f8', '2024-11-03 08:13:34', 'fa452b623e50')
    --  suite:      'TPC'
    --  benchmark:  'TPC-H'
    --  experiment: 'Q1'
    --  config:     'DuckDB (4 cores)'
    INSERT INTO "Measurements" ("timestamp", "experiment", "config", "case", "value", "run_id")
    VALUES
        (timestamp_id, experiment_id, configuration_id, 1, 75.0, 0),
        (timestamp_id, experiment_id, configuration_id, 1, 90.0, 1),
        (timestamp_id, experiment_id, configuration_id, 1, 70.0, 2),
        (timestamp_id, experiment_id, configuration_id, 1, 69.0, 3),
        (timestamp_id, experiment_id, configuration_id, 1, 66.0, 4);

    -- Get config
    PERFORM insert_configuration('HyPer (single core)', 'Execution Time');
    SELECT id FROM "Configurations"
    WHERE name='HyPer (single core)'
      AND parameters='Execution Time'
    INTO configuration_id;

    -- Write measurements
    --  timestamp:  ('a2b1bd45750ebc13a41ba169d377547cc54bc4f8', '2024-11-03 08:13:34', 'fa452b623e50')
    --  suite:      'TPC'
    --  benchmark:  'TPC-H'
    --  experiment: 'Q1'
    --  config:     'HyPer (single core)'
    INSERT INTO "Measurements" ("timestamp", "experiment", "config", "case", "value", "run_id")
    VALUES
        (timestamp_id, experiment_id, configuration_id, 1, 195.313, 0),
        (timestamp_id, experiment_id, configuration_id, 1, 192.84, 1),
        (timestamp_id, experiment_id, configuration_id, 1, 192.565, 2),
        (timestamp_id, experiment_id, configuration_id, 1, 192.338, 3),
        (timestamp_id, experiment_id, configuration_id, 1, 191.424, 4);

    -- Get config
    PERFORM insert_configuration('HyPer (4 cores)', 'Execution Time');
    SELECT id FROM "Configurations"
    WHERE name='HyPer (4 cores)'
      AND parameters='Execution Time'
    INTO configuration_id;

    -- Write measurements
    --  timestamp:  ('a2b1bd45750ebc13a41ba169d377547cc54bc4f8', '2024-11-03 08:13:34', 'fa452b623e50')
    --  suite:      'TPC'
    --  benchmark:  'TPC-H'
    --  experiment: 'Q1'
    --  config:     'HyPer (4 cores)'
    INSERT INTO "Measurements" ("timestamp", "experiment", "config", "case", "value", "run_id")
    VALUES
        (timestamp_id, experiment_id, configuration_id, 1, 55.629, 0),
        (timestamp_id, experiment_id, configuration_id, 1, 55.572, 1),
        (timestamp_id, experiment_id, configuration_id, 1, 55.564, 2),
        (timestamp_id, experiment_id, configuration_id, 1, 55.942, 3),
        (timestamp_id, experiment_id, configuration_id, 1, 56.021, 4);

    -- Get chart configuration
    PERFORM insert_chartconfig('linear', 'linear', 'O', 'Q', 'Scale factor', 'Execution time [ms]');
    SELECT id FROM "ChartConfig"
    WHERE scale_x='linear' AND scale_y='linear'
      AND type_x='O' AND type_y='Q'
      AND label_x='Scale factor' AND label_y='Execution time [ms]'
    INTO chartconfig_id;

    -- Get experiment
    PERFORM insert_experiment(benchmark_id, 'Q12', 1, 'TPC-H Query 12', TRUE, chartconfig_id);
    SELECT id FROM "Experiments"
    WHERE benchmark=benchmark_id
      AND name='Q12'
      AND version=1
    INTO experiment_id;

    -- Update chartconfig of this experiment (if a new one was inserted)
    UPDATE "Experiments"
    SET chart_config=chartconfig_id
    WHERE id=experiment_id;

    -- Get config
    PERFORM insert_configuration('mutable (single core, WasmV8, PAX4M)', 'Execution Time');
    SELECT id FROM "Configurations"
    WHERE name='mutable (single core, WasmV8, PAX4M)'
      AND parameters='Execution Time'
    INTO configuration_id;

    -- Write measurements
    --  timestamp:  ('a2b1bd45750ebc13a41ba169d377547cc54bc4f8', '2024-11-03 08:13:34', 'fa452b623e50')
    --  suite:      'TPC'
    --  benchmark:  'TPC-H'
    --  experiment: 'Q12'
    --  config:     'mutable (single core, WasmV8, PAX4M)'
    INSERT INTO "Measurements" ("timestamp", "experiment", "config", "case", "value", "run_id")
    VALUES
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 0),
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 1),
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 2),
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 3),
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 4);

    -- Get config
    PERFORM insert_configuration('DuckDB (single core)', 'Execution Time');
    SELECT id FROM "Configurations"
    WHERE name='DuckDB (single core)'
      AND parameters='Execution Time'
    INTO configuration_id;

    -- Write measurements
    --  timestamp:  ('a2b1bd45750ebc13a41ba169d377547cc54bc4f8', '2024-11-03 08:13:34', 'fa452b623e50')
    --  suite:      'TPC'
    --  benchmark:  'TPC-H'
    --  experiment: 'Q12'
    --  config:     'DuckDB (single core)'
    INSERT INTO "Measurements" ("timestamp", "experiment", "config", "case", "value", "run_id")
    VALUES
        (timestamp_id, experiment_id, configuration_id, 1, 147.0, 0),
        (timestamp_id, experiment_id, configuration_id, 1, 145.0, 1),
        (timestamp_id, experiment_id, configuration_id, 1, 120.0, 2),
        (timestamp_id, experiment_id, configuration_id, 1, 121.0, 3),
        (timestamp_id, experiment_id, configuration_id, 1, 142.0, 4);

    -- Get config
    PERFORM insert_configuration('DuckDB (4 cores)', 'Execution Time');
    SELECT id FROM "Configurations"
    WHERE name='DuckDB (4 cores)'
      AND parameters='Execution Time'
    INTO configuration_id;

    -- Write measurements
    --  timestamp:  ('a2b1bd45750ebc13a41ba169d377547cc54bc4f8', '2024-11-03 08:13:34', 'fa452b623e50')
    --  suite:      'TPC'
    --  benchmark:  'TPC-H'
    --  experiment: 'Q12'
    --  config:     'DuckDB (4 cores)'
    INSERT INTO "Measurements" ("timestamp", "experiment", "config", "case", "value", "run_id")
    VALUES
        (timestamp_id, experiment_id, configuration_id, 1, 87.0, 0),
        (timestamp_id, experiment_id, configuration_id, 1, 37.0, 1),
        (timestamp_id, experiment_id, configuration_id, 1, 94.0, 2),
        (timestamp_id, experiment_id, configuration_id, 1, 92.0, 3),
        (timestamp_id, experiment_id, configuration_id, 1, 33.0, 4);

    -- Get config
    PERFORM insert_configuration('PostgreSQL', 'Execution Time');
    SELECT id FROM "Configurations"
    WHERE name='PostgreSQL'
      AND parameters='Execution Time'
    INTO configuration_id;

    -- Write measurements
    --  timestamp:  ('a2b1bd45750ebc13a41ba169d377547cc54bc4f8', '2024-11-03 08:13:34', 'fa452b623e50')
    --  suite:      'TPC'
    --  benchmark:  'TPC-H'
    --  experiment: 'Q12'
    --  config:     'PostgreSQL'
    INSERT INTO "Measurements" ("timestamp", "experiment", "config", "case", "value", "run_id")
    VALUES
        (timestamp_id, experiment_id, configuration_id, 1, 2202.968, 0),
        (timestamp_id, experiment_id, configuration_id, 1, 791.861, 1),
        (timestamp_id, experiment_id, configuration_id, 1, 757.092, 2),
        (timestamp_id, experiment_id, configuration_id, 1, 786.139, 3),
        (timestamp_id, experiment_id, configuration_id, 1, 756.621, 4);

    -- Get config
    PERFORM insert_configuration('HyPer (single core)', 'Execution Time');
    SELECT id FROM "Configurations"
    WHERE name='HyPer (single core)'
      AND parameters='Execution Time'
    INTO configuration_id;

    -- Write measurements
    --  timestamp:  ('a2b1bd45750ebc13a41ba169d377547cc54bc4f8', '2024-11-03 08:13:34', 'fa452b623e50')
    --  suite:      'TPC'
    --  benchmark:  'TPC-H'
    --  experiment: 'Q12'
    --  config:     'HyPer (single core)'
    INSERT INTO "Measurements" ("timestamp", "experiment", "config", "case", "value", "run_id")
    VALUES
        (timestamp_id, experiment_id, configuration_id, 1, 30.662, 0),
        (timestamp_id, experiment_id, configuration_id, 1, 29.479, 1),
        (timestamp_id, experiment_id, configuration_id, 1, 29.402, 2),
        (timestamp_id, experiment_id, configuration_id, 1, 28.733, 3),
        (timestamp_id, experiment_id, configuration_id, 1, 30.573, 4);

    -- Get config
    PERFORM insert_configuration('HyPer (4 cores)', 'Execution Time');
    SELECT id FROM "Configurations"
    WHERE name='HyPer (4 cores)'
      AND parameters='Execution Time'
    INTO configuration_id;

    -- Write measurements
    --  timestamp:  ('a2b1bd45750ebc13a41ba169d377547cc54bc4f8', '2024-11-03 08:13:34', 'fa452b623e50')
    --  suite:      'TPC'
    --  benchmark:  'TPC-H'
    --  experiment: 'Q12'
    --  config:     'HyPer (4 cores)'
    INSERT INTO "Measurements" ("timestamp", "experiment", "config", "case", "value", "run_id")
    VALUES
        (timestamp_id, experiment_id, configuration_id, 1, 8.811, 0),
        (timestamp_id, experiment_id, configuration_id, 1, 8.627, 1),
        (timestamp_id, experiment_id, configuration_id, 1, 8.786, 2),
        (timestamp_id, experiment_id, configuration_id, 1, 8.801, 3),
        (timestamp_id, experiment_id, configuration_id, 1, 8.57, 4);

    -- Get chart configuration
    PERFORM insert_chartconfig('linear', 'linear', 'O', 'Q', 'Scale factor', 'Execution time [ms]');
    SELECT id FROM "ChartConfig"
    WHERE scale_x='linear' AND scale_y='linear'
      AND type_x='O' AND type_y='Q'
      AND label_x='Scale factor' AND label_y='Execution time [ms]'
    INTO chartconfig_id;

    -- Get experiment
    PERFORM insert_experiment(benchmark_id, 'Q14', 1, 'TPC-H Query 14', TRUE, chartconfig_id);
    SELECT id FROM "Experiments"
    WHERE benchmark=benchmark_id
      AND name='Q14'
      AND version=1
    INTO experiment_id;

    -- Update chartconfig of this experiment (if a new one was inserted)
    UPDATE "Experiments"
    SET chart_config=chartconfig_id
    WHERE id=experiment_id;

    -- Get config
    PERFORM insert_configuration('mutable (single core, WasmV8, PAX4M)', 'Execution Time');
    SELECT id FROM "Configurations"
    WHERE name='mutable (single core, WasmV8, PAX4M)'
      AND parameters='Execution Time'
    INTO configuration_id;

    -- Write measurements
    --  timestamp:  ('a2b1bd45750ebc13a41ba169d377547cc54bc4f8', '2024-11-03 08:13:34', 'fa452b623e50')
    --  suite:      'TPC'
    --  benchmark:  'TPC-H'
    --  experiment: 'Q14'
    --  config:     'mutable (single core, WasmV8, PAX4M)'
    INSERT INTO "Measurements" ("timestamp", "experiment", "config", "case", "value", "run_id")
    VALUES
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 0),
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 1),
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 2),
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 3),
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 4);

    -- Get config
    PERFORM insert_configuration('DuckDB (single core)', 'Execution Time');
    SELECT id FROM "Configurations"
    WHERE name='DuckDB (single core)'
      AND parameters='Execution Time'
    INTO configuration_id;

    -- Write measurements
    --  timestamp:  ('a2b1bd45750ebc13a41ba169d377547cc54bc4f8', '2024-11-03 08:13:34', 'fa452b623e50')
    --  suite:      'TPC'
    --  benchmark:  'TPC-H'
    --  experiment: 'Q14'
    --  config:     'DuckDB (single core)'
    INSERT INTO "Measurements" ("timestamp", "experiment", "config", "case", "value", "run_id")
    VALUES
        (timestamp_id, experiment_id, configuration_id, 1, 77.0, 0),
        (timestamp_id, experiment_id, configuration_id, 1, 81.0, 1),
        (timestamp_id, experiment_id, configuration_id, 1, 81.0, 2),
        (timestamp_id, experiment_id, configuration_id, 1, 82.0, 3),
        (timestamp_id, experiment_id, configuration_id, 1, 60.0, 4);

    -- Get config
    PERFORM insert_configuration('DuckDB (4 cores)', 'Execution Time');
    SELECT id FROM "Configurations"
    WHERE name='DuckDB (4 cores)'
      AND parameters='Execution Time'
    INTO configuration_id;

    -- Write measurements
    --  timestamp:  ('a2b1bd45750ebc13a41ba169d377547cc54bc4f8', '2024-11-03 08:13:34', 'fa452b623e50')
    --  suite:      'TPC'
    --  benchmark:  'TPC-H'
    --  experiment: 'Q14'
    --  config:     'DuckDB (4 cores)'
    INSERT INTO "Measurements" ("timestamp", "experiment", "config", "case", "value", "run_id")
    VALUES
        (timestamp_id, experiment_id, configuration_id, 1, 42.0, 0),
        (timestamp_id, experiment_id, configuration_id, 1, 31.0, 1),
        (timestamp_id, experiment_id, configuration_id, 1, 25.0, 2),
        (timestamp_id, experiment_id, configuration_id, 1, 41.0, 3),
        (timestamp_id, experiment_id, configuration_id, 1, 31.0, 4);

    -- Get config
    PERFORM insert_configuration('PostgreSQL', 'Execution Time');
    SELECT id FROM "Configurations"
    WHERE name='PostgreSQL'
      AND parameters='Execution Time'
    INTO configuration_id;

    -- Write measurements
    --  timestamp:  ('a2b1bd45750ebc13a41ba169d377547cc54bc4f8', '2024-11-03 08:13:34', 'fa452b623e50')
    --  suite:      'TPC'
    --  benchmark:  'TPC-H'
    --  experiment: 'Q14'
    --  config:     'PostgreSQL'
    INSERT INTO "Measurements" ("timestamp", "experiment", "config", "case", "value", "run_id")
    VALUES
        (timestamp_id, experiment_id, configuration_id, 1, 614.193, 0),
        (timestamp_id, experiment_id, configuration_id, 1, 561.188, 1),
        (timestamp_id, experiment_id, configuration_id, 1, 557.173, 2),
        (timestamp_id, experiment_id, configuration_id, 1, 561.869, 3),
        (timestamp_id, experiment_id, configuration_id, 1, 558.859, 4);

    -- Get config
    PERFORM insert_configuration('HyPer (single core)', 'Execution Time');
    SELECT id FROM "Configurations"
    WHERE name='HyPer (single core)'
      AND parameters='Execution Time'
    INTO configuration_id;

    -- Write measurements
    --  timestamp:  ('a2b1bd45750ebc13a41ba169d377547cc54bc4f8', '2024-11-03 08:13:34', 'fa452b623e50')
    --  suite:      'TPC'
    --  benchmark:  'TPC-H'
    --  experiment: 'Q14'
    --  config:     'HyPer (single core)'
    INSERT INTO "Measurements" ("timestamp", "experiment", "config", "case", "value", "run_id")
    VALUES
        (timestamp_id, experiment_id, configuration_id, 1, 19.299, 0),
        (timestamp_id, experiment_id, configuration_id, 1, 14.23, 1),
        (timestamp_id, experiment_id, configuration_id, 1, 19.033, 2),
        (timestamp_id, experiment_id, configuration_id, 1, 15.098, 3),
        (timestamp_id, experiment_id, configuration_id, 1, 16.772, 4);

    -- Get config
    PERFORM insert_configuration('HyPer (4 cores)', 'Execution Time');
    SELECT id FROM "Configurations"
    WHERE name='HyPer (4 cores)'
      AND parameters='Execution Time'
    INTO configuration_id;

    -- Write measurements
    --  timestamp:  ('a2b1bd45750ebc13a41ba169d377547cc54bc4f8', '2024-11-03 08:13:34', 'fa452b623e50')
    --  suite:      'TPC'
    --  benchmark:  'TPC-H'
    --  experiment: 'Q14'
    --  config:     'HyPer (4 cores)'
    INSERT INTO "Measurements" ("timestamp", "experiment", "config", "case", "value", "run_id")
    VALUES
        (timestamp_id, experiment_id, configuration_id, 1, 7.885, 0),
        (timestamp_id, experiment_id, configuration_id, 1, 8.517, 1),
        (timestamp_id, experiment_id, configuration_id, 1, 5.544, 2),
        (timestamp_id, experiment_id, configuration_id, 1, 5.314, 3),
        (timestamp_id, experiment_id, configuration_id, 1, 5.828, 4);

    -- Get chart configuration
    PERFORM insert_chartconfig('linear', 'linear', 'O', 'Q', 'Scale factor', 'Execution time [ms]');
    SELECT id FROM "ChartConfig"
    WHERE scale_x='linear' AND scale_y='linear'
      AND type_x='O' AND type_y='Q'
      AND label_x='Scale factor' AND label_y='Execution time [ms]'
    INTO chartconfig_id;

    -- Get experiment
    PERFORM insert_experiment(benchmark_id, 'Q3', 1, 'TPC-H Query 3', TRUE, chartconfig_id);
    SELECT id FROM "Experiments"
    WHERE benchmark=benchmark_id
      AND name='Q3'
      AND version=1
    INTO experiment_id;

    -- Update chartconfig of this experiment (if a new one was inserted)
    UPDATE "Experiments"
    SET chart_config=chartconfig_id
    WHERE id=experiment_id;

    -- Get config
    PERFORM insert_configuration('mutable (single core, WasmV8, PAX4M)', 'Execution Time');
    SELECT id FROM "Configurations"
    WHERE name='mutable (single core, WasmV8, PAX4M)'
      AND parameters='Execution Time'
    INTO configuration_id;

    -- Write measurements
    --  timestamp:  ('a2b1bd45750ebc13a41ba169d377547cc54bc4f8', '2024-11-03 08:13:34', 'fa452b623e50')
    --  suite:      'TPC'
    --  benchmark:  'TPC-H'
    --  experiment: 'Q3'
    --  config:     'mutable (single core, WasmV8, PAX4M)'
    INSERT INTO "Measurements" ("timestamp", "experiment", "config", "case", "value", "run_id")
    VALUES
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 0),
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 1),
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 2),
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 3),
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 4);

    -- Get config
    PERFORM insert_configuration('DuckDB (single core)', 'Execution Time');
    SELECT id FROM "Configurations"
    WHERE name='DuckDB (single core)'
      AND parameters='Execution Time'
    INTO configuration_id;

    -- Write measurements
    --  timestamp:  ('a2b1bd45750ebc13a41ba169d377547cc54bc4f8', '2024-11-03 08:13:34', 'fa452b623e50')
    --  suite:      'TPC'
    --  benchmark:  'TPC-H'
    --  experiment: 'Q3'
    --  config:     'DuckDB (single core)'
    INSERT INTO "Measurements" ("timestamp", "experiment", "config", "case", "value", "run_id")
    VALUES
        (timestamp_id, experiment_id, configuration_id, 1, 153.0, 0),
        (timestamp_id, experiment_id, configuration_id, 1, 157.0, 1),
        (timestamp_id, experiment_id, configuration_id, 1, 144.0, 2),
        (timestamp_id, experiment_id, configuration_id, 1, 149.0, 3),
        (timestamp_id, experiment_id, configuration_id, 1, 153.0, 4);

    -- Get config
    PERFORM insert_configuration('DuckDB (4 cores)', 'Execution Time');
    SELECT id FROM "Configurations"
    WHERE name='DuckDB (4 cores)'
      AND parameters='Execution Time'
    INTO configuration_id;

    -- Write measurements
    --  timestamp:  ('a2b1bd45750ebc13a41ba169d377547cc54bc4f8', '2024-11-03 08:13:34', 'fa452b623e50')
    --  suite:      'TPC'
    --  benchmark:  'TPC-H'
    --  experiment: 'Q3'
    --  config:     'DuckDB (4 cores)'
    INSERT INTO "Measurements" ("timestamp", "experiment", "config", "case", "value", "run_id")
    VALUES
        (timestamp_id, experiment_id, configuration_id, 1, 49.0, 0),
        (timestamp_id, experiment_id, configuration_id, 1, 44.0, 1),
        (timestamp_id, experiment_id, configuration_id, 1, 55.0, 2),
        (timestamp_id, experiment_id, configuration_id, 1, 44.0, 3),
        (timestamp_id, experiment_id, configuration_id, 1, 44.0, 4);

    -- Get config
    PERFORM insert_configuration('PostgreSQL', 'Execution Time');
    SELECT id FROM "Configurations"
    WHERE name='PostgreSQL'
      AND parameters='Execution Time'
    INTO configuration_id;

    -- Write measurements
    --  timestamp:  ('a2b1bd45750ebc13a41ba169d377547cc54bc4f8', '2024-11-03 08:13:34', 'fa452b623e50')
    --  suite:      'TPC'
    --  benchmark:  'TPC-H'
    --  experiment: 'Q3'
    --  config:     'PostgreSQL'
    INSERT INTO "Measurements" ("timestamp", "experiment", "config", "case", "value", "run_id")
    VALUES
        (timestamp_id, experiment_id, configuration_id, 1, 3138.259, 0),
        (timestamp_id, experiment_id, configuration_id, 1, 5186.671, 1),
        (timestamp_id, experiment_id, configuration_id, 1, 2394.153, 2),
        (timestamp_id, experiment_id, configuration_id, 1, 2056.408, 3),
        (timestamp_id, experiment_id, configuration_id, 1, 3839.944, 4);

    -- Get config
    PERFORM insert_configuration('HyPer (single core)', 'Execution Time');
    SELECT id FROM "Configurations"
    WHERE name='HyPer (single core)'
      AND parameters='Execution Time'
    INTO configuration_id;

    -- Write measurements
    --  timestamp:  ('a2b1bd45750ebc13a41ba169d377547cc54bc4f8', '2024-11-03 08:13:34', 'fa452b623e50')
    --  suite:      'TPC'
    --  benchmark:  'TPC-H'
    --  experiment: 'Q3'
    --  config:     'HyPer (single core)'
    INSERT INTO "Measurements" ("timestamp", "experiment", "config", "case", "value", "run_id")
    VALUES
        (timestamp_id, experiment_id, configuration_id, 1, 88.694, 0),
        (timestamp_id, experiment_id, configuration_id, 1, 87.271, 1),
        (timestamp_id, experiment_id, configuration_id, 1, 78.708, 2),
        (timestamp_id, experiment_id, configuration_id, 1, 79.1, 3),
        (timestamp_id, experiment_id, configuration_id, 1, 87.861, 4);

    -- Get config
    PERFORM insert_configuration('HyPer (4 cores)', 'Execution Time');
    SELECT id FROM "Configurations"
    WHERE name='HyPer (4 cores)'
      AND parameters='Execution Time'
    INTO configuration_id;

    -- Write measurements
    --  timestamp:  ('a2b1bd45750ebc13a41ba169d377547cc54bc4f8', '2024-11-03 08:13:34', 'fa452b623e50')
    --  suite:      'TPC'
    --  benchmark:  'TPC-H'
    --  experiment: 'Q3'
    --  config:     'HyPer (4 cores)'
    INSERT INTO "Measurements" ("timestamp", "experiment", "config", "case", "value", "run_id")
    VALUES
        (timestamp_id, experiment_id, configuration_id, 1, 26.123, 0),
        (timestamp_id, experiment_id, configuration_id, 1, 26.332, 1),
        (timestamp_id, experiment_id, configuration_id, 1, 32.468, 2),
        (timestamp_id, experiment_id, configuration_id, 1, 26.292, 3),
        (timestamp_id, experiment_id, configuration_id, 1, 26.498, 4);

    -- Get chart configuration
    PERFORM insert_chartconfig('linear', 'linear', 'O', 'Q', 'Scale factor', 'Execution time [ms]');
    SELECT id FROM "ChartConfig"
    WHERE scale_x='linear' AND scale_y='linear'
      AND type_x='O' AND type_y='Q'
      AND label_x='Scale factor' AND label_y='Execution time [ms]'
    INTO chartconfig_id;

    -- Get experiment
    PERFORM insert_experiment(benchmark_id, 'Q6', 1, 'TPC-H Query 6', TRUE, chartconfig_id);
    SELECT id FROM "Experiments"
    WHERE benchmark=benchmark_id
      AND name='Q6'
      AND version=1
    INTO experiment_id;

    -- Update chartconfig of this experiment (if a new one was inserted)
    UPDATE "Experiments"
    SET chart_config=chartconfig_id
    WHERE id=experiment_id;

    -- Get config
    PERFORM insert_configuration('mutable (single core, WasmV8, PAX4M)', 'Execution Time');
    SELECT id FROM "Configurations"
    WHERE name='mutable (single core, WasmV8, PAX4M)'
      AND parameters='Execution Time'
    INTO configuration_id;

    -- Write measurements
    --  timestamp:  ('a2b1bd45750ebc13a41ba169d377547cc54bc4f8', '2024-11-03 08:13:34', 'fa452b623e50')
    --  suite:      'TPC'
    --  benchmark:  'TPC-H'
    --  experiment: 'Q6'
    --  config:     'mutable (single core, WasmV8, PAX4M)'
    INSERT INTO "Measurements" ("timestamp", "experiment", "config", "case", "value", "run_id")
    VALUES
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 0),
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 1),
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 2),
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 3),
        (timestamp_id, experiment_id, configuration_id, 1, 10000.0, 4);

    -- Get config
    PERFORM insert_configuration('DuckDB (single core)', 'Execution Time');
    SELECT id FROM "Configurations"
    WHERE name='DuckDB (single core)'
      AND parameters='Execution Time'
    INTO configuration_id;

    -- Write measurements
    --  timestamp:  ('a2b1bd45750ebc13a41ba169d377547cc54bc4f8', '2024-11-03 08:13:34', 'fa452b623e50')
    --  suite:      'TPC'
    --  benchmark:  'TPC-H'
    --  experiment: 'Q6'
    --  config:     'DuckDB (single core)'
    INSERT INTO "Measurements" ("timestamp", "experiment", "config", "case", "value", "run_id")
    VALUES
        (timestamp_id, experiment_id, configuration_id, 1, 77.0, 0),
        (timestamp_id, experiment_id, configuration_id, 1, 71.0, 1),
        (timestamp_id, experiment_id, configuration_id, 1, 47.0, 2),
        (timestamp_id, experiment_id, configuration_id, 1, 78.0, 3),
        (timestamp_id, experiment_id, configuration_id, 1, 52.0, 4);

    -- Get config
    PERFORM insert_configuration('DuckDB (4 cores)', 'Execution Time');
    SELECT id FROM "Configurations"
    WHERE name='DuckDB (4 cores)'
      AND parameters='Execution Time'
    INTO configuration_id;

    -- Write measurements
    --  timestamp:  ('a2b1bd45750ebc13a41ba169d377547cc54bc4f8', '2024-11-03 08:13:34', 'fa452b623e50')
    --  suite:      'TPC'
    --  benchmark:  'TPC-H'
    --  experiment: 'Q6'
    --  config:     'DuckDB (4 cores)'
    INSERT INTO "Measurements" ("timestamp", "experiment", "config", "case", "value", "run_id")
    VALUES
        (timestamp_id, experiment_id, configuration_id, 1, 16.0, 0),
        (timestamp_id, experiment_id, configuration_id, 1, 15.0, 1),
        (timestamp_id, experiment_id, configuration_id, 1, 17.0, 2),
        (timestamp_id, experiment_id, configuration_id, 1, 16.0, 3),
        (timestamp_id, experiment_id, configuration_id, 1, 15.0, 4);

    -- Get config
    PERFORM insert_configuration('PostgreSQL', 'Execution Time');
    SELECT id FROM "Configurations"
    WHERE name='PostgreSQL'
      AND parameters='Execution Time'
    INTO configuration_id;

    -- Write measurements
    --  timestamp:  ('a2b1bd45750ebc13a41ba169d377547cc54bc4f8', '2024-11-03 08:13:34', 'fa452b623e50')
    --  suite:      'TPC'
    --  benchmark:  'TPC-H'
    --  experiment: 'Q6'
    --  config:     'PostgreSQL'
    INSERT INTO "Measurements" ("timestamp", "experiment", "config", "case", "value", "run_id")
    VALUES
        (timestamp_id, experiment_id, configuration_id, 1, 565.406, 0),
        (timestamp_id, experiment_id, configuration_id, 1, 523.797, 1),
        (timestamp_id, experiment_id, configuration_id, 1, 533.937, 2),
        (timestamp_id, experiment_id, configuration_id, 1, 524.393, 3),
        (timestamp_id, experiment_id, configuration_id, 1, 536.558, 4);

    -- Get config
    PERFORM insert_configuration('HyPer (single core)', 'Execution Time');
    SELECT id FROM "Configurations"
    WHERE name='HyPer (single core)'
      AND parameters='Execution Time'
    INTO configuration_id;

    -- Write measurements
    --  timestamp:  ('a2b1bd45750ebc13a41ba169d377547cc54bc4f8', '2024-11-03 08:13:34', 'fa452b623e50')
    --  suite:      'TPC'
    --  benchmark:  'TPC-H'
    --  experiment: 'Q6'
    --  config:     'HyPer (single core)'
    INSERT INTO "Measurements" ("timestamp", "experiment", "config", "case", "value", "run_id")
    VALUES
        (timestamp_id, experiment_id, configuration_id, 1, 11.603, 0),
        (timestamp_id, experiment_id, configuration_id, 1, 11.606, 1),
        (timestamp_id, experiment_id, configuration_id, 1, 11.52, 2),
        (timestamp_id, experiment_id, configuration_id, 1, 11.301, 3),
        (timestamp_id, experiment_id, configuration_id, 1, 11.595, 4);

    -- Get config
    PERFORM insert_configuration('HyPer (4 cores)', 'Execution Time');
    SELECT id FROM "Configurations"
    WHERE name='HyPer (4 cores)'
      AND parameters='Execution Time'
    INTO configuration_id;

    -- Write measurements
    --  timestamp:  ('a2b1bd45750ebc13a41ba169d377547cc54bc4f8', '2024-11-03 08:13:34', 'fa452b623e50')
    --  suite:      'TPC'
    --  benchmark:  'TPC-H'
    --  experiment: 'Q6'
    --  config:     'HyPer (4 cores)'
    INSERT INTO "Measurements" ("timestamp", "experiment", "config", "case", "value", "run_id")
    VALUES
        (timestamp_id, experiment_id, configuration_id, 1, 3.049, 0),
        (timestamp_id, experiment_id, configuration_id, 1, 3.542, 1),
        (timestamp_id, experiment_id, configuration_id, 1, 3.033, 2),
        (timestamp_id, experiment_id, configuration_id, 1, 3.046, 3),
        (timestamp_id, experiment_id, configuration_id, 1, 3.008, 4);
END$$;