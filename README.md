# Quickly Enable PostgreSQL REST API with PostgREST.

This SQL script could be used to populate sample roles, sample table, enable login mechanism using JWT token.

Usage:
1. Create a PostgreSQL database
2. Enable these extensions:
    - pgcrypto
    - pgjwt
    - postgis (optional, if you want to use spatial data with PostgREST > 10)
3. Replace all occurence of these parameters with your own:
    - authenticator pwd: __authenticator_password__
    - jwt key: __jwt_key__
    - authenticated user: __authenticated_user__
    - dbname: __db_name__
4. Execute modified sql script inside your database, with postgres user


