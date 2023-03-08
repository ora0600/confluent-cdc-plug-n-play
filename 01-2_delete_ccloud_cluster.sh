#!/bin/bash

export CLUSTERID1KEY=$(awk '/key:/{print $NF}' clusterid1_key)
export CLUSTERID1SECRET=$(awk '/secret:/{print $NF}' clusterid1_key )
export CCLOUD_CLUSTERID1=$(awk '/id:/{print $NF}' clusterid1)
export CCLOUD_CLUSTERID1_BOOTSTRAP=$(awk '/endpoint: SASL_SSL:\/\//{print $NF}' clusterid1 | sed 's/SASL_SSL:\/\///g')
export ENVID=$(awk '/id:/{print $NF}' env)
export environment=$ENVID
export source_id=$CCLOUD_CLUSTERID1
export source_endpoint=$CCLOUD_CLUSTERID1_BOOTSTRAP
export sourcekey=$CLUSTERID1KEY
export sourcesecret=$CLUSTERID1SECRET
export SRCLUSTERID=$(awk '/id:/{print $NF}' schemareg)
export SRCLUSTERKEY=$(awk '/key:/{print $NF}'  srclusterid1_key)
export srid=$SRCLUSTERID
export srkey=$SRCLUSTERKEY

echo "delete everything form this demo"
echo "API Keys"
confluent api-key delete $sourcekey
confluent api-key delete $srkey

echo "Source cluster"
confluent kafka cluster delete $source_id --environment $environment

echo "Schema Registry"
confluent schema-registry cluster delete --environment $environment

echo "environment"
confluent environment delete $environment

echo "files"
rm basedir
rm clusterid1
rm clusterid1_key
rm env
rm env-vars
rm schemareg
rm srclusterid1_key
rm oraclecdc19c-config.properties
rm cdc-connect-standalone.properties
rm topicname

echo "Demo Environment deleted"