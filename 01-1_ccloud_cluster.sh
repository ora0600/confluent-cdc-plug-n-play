#!/bin/bash
# Create Confluent Cloud Cluster


pwd > basedir
export BASEDIR=$(cat basedir)
echo $BASEDIR

source ${BASEDIR}/config.properties

export uuid=$(uuidgen)
export env=ccloud-oracdc-$uuid
# create cluster source and env
confluent login
# Environments
echo "confluent environment create $env"
confluent environment create $env -o yaml > env
export ENVID=$(awk '/id:/{print $NF}' env)
echo $ENVID
# Cluster creation
confluent kafka cluster create ora-cdc-cluster --cloud 'gcp' --region 'europe-west1' --type basic --environment $ENVID -o yaml > clusterid1
echo "clusters created wait 30 sec"
sleep 30
# set cluster id as parameter
export CCLOUD_CLUSTERID1=$(awk '/id:/{print $NF}' clusterid1)
confluent kafka cluster describe $CCLOUD_CLUSTERID1 --environment $ENVID -o yaml > clusterid1
export CCLOUD_CLUSTERID1_BOOTSTRAP=$(awk '/endpoint: SASL_SSL:\/\//{print $NF}' clusterid1 | sed 's/SASL_SSL:\/\///g')

# Create API Keys for cluster
confluent api-key create --resource $CCLOUD_CLUSTERID1 --description " Key for $CCLOUD_CLUSTERID1" --environment $ENVID -o yaml > clusterid1_key
export CLUSTERID1KEY=$(awk '/key:/{print $NF}' clusterid1_key)
export CLUSTERID1SECRET=$(awk '/secret:/{print $NF}' clusterid1_key )
echo "Source Key for source cluster"
cat clusterid1_key
echo "API keys for clusters are created wait 30 sec..."
sleep 30

#enable Schema Registry for the confluent cloud cluster in Environment
confluent environment use $environment
confluent schema-registry cluster enable --cloud gcp --geo eu --package essentials --environment $ENVID -o yaml > schemareg
export SRCLUSTERID=$(awk '/id:/{print $NF}' schemareg)
export SRCLUSTERURL=$(awk '/endpoint_url:/{print $NF}' schemareg )
echo "Schema Registry was enabled"
confluent api-key create --resource $SRCLUSTERID --description " Key for SR SRCLUSTERID" --environment $ENVID -o yaml > srclusterid1_key
export SRCLUSTERKEY=$(awk '/key:/{print $NF}'  srclusterid1_key)
export SRCLUSTERSECRET=$(awk '/secret:/{print $NF}'  srclusterid1_key)
echo "Key for SR cluster"
cat srclusterid1_key

echo "topicname: $tablename" | sed -r 's/\[.\]+/./g' > topicname
export topicname=$(awk '/topicname:/{print $NF}'  topicname)
export environment=$ENVID
export source_id=$CCLOUD_CLUSTERID1
export source_endpoint=$CCLOUD_CLUSTERID1_BOOTSTRAP
export sourcekey=$CLUSTERID1KEY
export sourcesecret=$CLUSTERID1SECRET
export srid=$SRCLUSTERID
export srurl=$SRCLUSTERURL
export srkey=$SRCLUSTERKEY
export srsecret=$SRCLUSTERSECRET

echo "cluster created:$CCLOUD_CLUSTERID1 and $SRCLUSTERID"

# use created environment
confluent environment use $environment

# End of Cluster Setup
echo "<<<<<<<<<<<< End of Cluster Setup"

# write proptery file
echo "export environment=$ENVID
export source_id=$CCLOUD_CLUSTERID1
export source_endpoint=$CCLOUD_CLUSTERID1_BOOTSTRAP
export sourcekey=$CLUSTERID1KEY
export sourcesecret=$CLUSTERID1SECRET
export srid=$SRCLUSTERID
export srurl=$SRCLUSTERURL
export srkey=$SRCLUSTERKEY
export srsecret=$SRCLUSTERSECRET
export topicname=$topicname
export healthpluskey=$healthpluskey
export healthplussecret=$healthplussecret" > env-vars





