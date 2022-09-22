Contents of this docker-compose
===============================


This is the old school Metabase + postgreSQL as the Application database.

- Metabase is exposed through port 3001
- PosgreSQL is exposed through port 5432

both containers are in the same metanet1 network and you can wipe postgreSQL database by doing sudo `rm -rf /postgres_origin` on this folder (/environments/postgres)