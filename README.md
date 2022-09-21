# Quickly Enable PostgreSQL REST API with PostgREST.

The SQL script could be used to populate sample roles, sample table, enable login mechanism using JWT token.

Usage:
1. Create a PostgreSQL database
2. Enable these extensions:
    - pgcrypto
    - pgjwt
    - postgis (optional, if you want to use spatial data with PostgREST > 10)
3. Replace all occurence of these parameters with your own:
    - authenticator pwd: \_\_authenticator_password\_\_
    - jwt key: \_\_jwt_key\_\_
    - authenticated user: \_\_authenticated_user\_\_
    - dbname: \_\_db_name\_\_
4. Execute modified sql script inside your database, with postgres user


The config sample could be use as PostgREST cofiguration file.
