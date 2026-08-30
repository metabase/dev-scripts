## What
This docker-compose will simply start Metabase with a PostgreSQL app db and will create the admin user

## How
A setup container runs a shell script which will wait for Metabase to be alive and then set it up with:
user: a@b.com
pass: metabot1

## Additions
The script will also add the PostgreSQL database with sample data to Metabase.