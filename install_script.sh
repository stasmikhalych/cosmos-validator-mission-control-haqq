#!/bin/bash

set -e

cd $HOME

teleFalg="$1"
teleFlagValue="--remote-hosted"

echo "----------- Installing grafana -----------"

sudo -S apt-get install -y adduser libfontconfig1

sudo apt-get install -y apt-transport-https

sudo apt-get install -y software-properties-common wget

sudo wget -q -O /usr/share/keyrings/grafana.key https://packages.grafana.com/gpg.key

echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

sudo apt-get update

sudo apt-get install grafana-enterprise

echo "------ Starting grafana server using systemd --------"

sudo -S systemctl daemon-reload

sudo -S systemctl start grafana-server

cd $HOME

echo "----------- Installing Influx -----------"

wget -qO- https://repos.influxdata.com/influxdb.key | sudo apt-key add -
source /etc/lsb-release
echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/influxdb.list

sudo -S apt-get update && sudo apt-get install influxdb
sudo -S service influxdb start

cd $HOME

if [ "$teleFalg" != "$teleFlagValue" ];
then 
	echo "----------- Installing telegraf -----------------"
	
	sudo -S apt-get update && sudo apt-get install telegraf
	sudo -S service telegraf start

else
	echo "------remote-hosted enabled, so not downloading the telegraf--------"
fi

echo "------------Creating databases vcf and telegraf-------------"

curl "http://localhost:8086/query" --data-urlencode "q=CREATE DATABASE vcf"

curl "http://localhost:8086/query" --data-urlencode "q=CREATE DATABASE telegraf"


echo "--------- Cloning cosmos-validator-mission-control -----------"

cd go/src/github.com

git clone https://github.com/stasmikhalyh/cosmos-validator-mission-control-haqq.git

cd cosmos-validator-mission-control

cp example.config.toml config.toml 

echo "------ Building and running the code --------"

go build && ./cosmos-validator-mission-control
