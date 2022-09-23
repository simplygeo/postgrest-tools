#!/bin/bash

export AUTHENTICATOR_PASSWORD=nobitanobi
export JWT_KEY=12345678901234567890123456789012
export SAMPLE_USER=suneo
export DB_NAME=geodb
export POSTGREST_BIN=https://github.com/PostgREST/postgrest/releases/download/v10.0.0/postgrest-v10.0.0-linux-static-x64.tar.xz


echo ""
echo "Downloading required packages..."
sleep 3
sudo apt update
sudo apt install -y git postgresql-14 postgresql-server-dev-14 build-essential postgresql-14-postgis-3

echo ""
echo "Preparing sql & config file..."
sleep 3
wget https://raw.githubusercontent.com/simplygeo/postgrest-tools/main/postgrest-sample.sql
wget -O postgrest.conf https://raw.githubusercontent.com/simplygeo/postgrest-tools/main/postgrest-config-sample.conf
sed -i "s/__authenticator_password__/$AUTHENTICATOR_PASSWORD/g" postgrest-sample.sql
sed -i "s/__jwt_key__/$JWT_KEY/g" postgrest-sample.sql
sed -i "s/__sample_user__/$SAMPLE_USER/g" postgrest-sample.sql
sed -i "s/__db_name__/$DB_NAME/g" postgrest-sample.sql
sed -i "s/__authenticator_password__/$AUTHENTICATOR_PASSWORD/g" postgrest.conf
sed -i "s/__jwt_key__/$JWT_KEY/g" postgrest.conf
sed -i "s/__db_name__/$DB_NAME/g" postgrest.conf

cp postgrest-sample.sql /tmp
sudo cp postgrest.conf /etc/postgrest.conf


echo ""
echo "Building pgjwt..."
sleep 3
git clone https://github.com/michelp/pgjwt.git
cd pgjwt
sudo make install
cd ..


echo ""
echo "Creating database..."
sleep 3
sudo -u postgres psql -c "CREATE DATABASE $DB_NAME;"

echo ""
echo "Preparing PostgREST API sample..."
sleep 3
sudo -u postgres psql -d $DB_NAME -f /tmp/postgrest-sample.sql
sudo rm /tmp/postgrest-sample.sql


echo ""
sleep 3
echo "Download PostgREST..."
wget -O postgrest.tar.xz $POSTGREST_BIN
tar xvfJ ./postgrest.tar.xz
sudo mv postgrest /bin

echo ""
sleep 3
echo "Run PostgREST as service..."
sudo wget -O /etc/systemd/system/postgrest.service https://raw.githubusercontent.com/simplygeo/postgrest-tools/main/postgrest.service.sample
sudo systemctl start postgrest
sudo systemctl enable postgrest 
sudo systemctl status postgrest

# Cleaning....
rm -rf ./pgjwt
rm postgrest-sample.sql
rm postgrest.conf
rm postgrest.tar.xz

