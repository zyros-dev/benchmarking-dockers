1. Build the image with docker compose build
2. Do docker compose up 
3. With a different terminal do  

```
docker exec -it mutable_benchmarks-mutable_bench-1 /bin/bash
su - postgres
/usr/lib/postgresql/17/bin/pg_ctl -D /var/lib/postgresql/data -l /var/lib/postgresql/data/logfile start
logout
```
```
```
