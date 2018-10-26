#!/bin/bash -xe

###############################################################################
#	@file	ElasticSearch环境安装.sh
#	@brief	安装环境
#	@authors  xiaojin  2018-10-26
###############################################################################

ES_CONF=/etc/elasticsearch/elasticsearch.yml
ES_SERVICES=/usr/lib/systemd/system/elasticsearch.service

function Install_rpms()
{
	yum install -y jre
	wget -P /tmp https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.6.6.rpm
	rpm -ivh /tmp/elasticsearch-5.6.6.rpm
	#/usr/share/elasticsearch/bin/elasticsearch-plugin install https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v5.6.6/elasticsearch-analysis-ik-5.6.6.zip
}

function Config_Es()
{
    systemctl enable elasticsearch
    if ! grep -q "Restart=always" ${ES_SERVICES}; then
        sed -i '/^\[Service\]*/a Restart=always' $ES_SERVICES
        systemctl daemon-reload
    fi
    sed -ri '/cluster.name/c cluster.name: ainiok' ${ES_CONF}
    sed -ri "/node.name/c node.name: node-1" ${ES_CONF}
    sed -ri "/network.host/c network.host: 192.168.0.1" ${ES_CONF}

    sysctl -w vm.max_map_count=262144
    systemctl start elasticsearch
    echo "Waitting for elasticsearch start"

    max_try=20
    while [ "$max_try" -gt 0 ];do
        ES_ID=$(pgrep -f go-mysql-elasticsearch|head -n 1)
        if [ -n "$ES_ID" ];then
           break
        fi
        let max_try--
        sleep 15
    done
    # curl -XPUT 192.168.0.1:9200/_template/common -d "$MAPPING"
}
Install_rpms
Config_Es