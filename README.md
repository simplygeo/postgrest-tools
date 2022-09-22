# Quickly Run PostgREST with JWT Authentication - Ubuntu Linux
(tested with Ubuntu 22.04 Jammy)

PostgREST enable REST API with PostgreSQL backend.

This tool could be used to populate sample roles, sample table, enable login mechanism using JWT token.

## Usage:

1. Download postgrest-install.sh

    wget https://raw.githubusercontent.com/simplygeo/postgrest-tools/main/postgrest-install.sh

2. Modify postgresql-install.sh

    AUTHENTICATOR_PASSWORD: password for user 'authenticator'

    JWT_KEY: JWT key (at least 32 byte random alphanumeric)

    SAMPLE_USER: sample username (email would be <username>@gmail.com, password <username>)

    DB_NAME: database name

    POSTGREST_BIN: PostgREST binary download URL, e.g. https://github.com/PostgREST/postgrest/releases/download/v10.0.0/postgrest-v10.0.0-linux-static-x64.tar.xz

3. Make it executable

    chmod +x ./postgrest-install.sh

4. Run it

    ./postgrest-install.sh


## Test

By the end of installation process:
- PostgREST should be running as service, at port 3000
- Anonymouse user could get /todos endpoint
- User could login using /rpc/login endpoint
    - try user: suneo@gmail.com, pwd: suneo (if you use default setting)
    - we should get generated JWT token
- User could get /gpstrack endpoint using generated token --> this is example of postgis spatial table

