#!/bin/sh

# ## **********************************************************
# ## File:        Start Confluent CDC Connector for Oracle Demo
# ## Project:     Oracle CDC Connector from Confluent
# ## Author:      C.Muetzlitz
# ## Version:     0.1
# ## Create:      7.3.2023
# ## Modify:      7.3.2023
# ## Description: Creates a Demo for CDC from Oracle to 
# ##              Confluent Cloud, Customers can use own DB
# ## **********************************************************

### **********************************************************
###
###       init. Read current parameters for this demo setup
###       Read parameters from config.properties
###    
### **********************************************************

initialisiere()
{
	# Read env from config.properties
  source ./config.properties
  # Current Hostname
	HOST=`hostname`
  # current date
	DATE=`date +%m-%d-%y.%H:%M`
	# Name der Log#Datei, in der alles protokolliert wird
	LOGFILE=00_StartConfluentCDCDemoSetup_${BUILDNR}_${DATE}.log
	# Read Parameter from Config File
  CONFIGFILE=$STARTDIR/config.properties
  source $CONFIGFILE
  echo "***********************************************************"
  echo "The following parameters will be used for build this demo->"
  echo "-> Health+ Key <${healthpluskey}> and Secret <${healthplussecret}>"
  echo "-> Host of Oracle Server <${oraserver}> and Port <${oraport}>"
  echo "-> SID of Oracle Server <${orasid}>"
  echo "-> Servicename of Oracle Server PDB <${orapdbname}>"
  echo "-> Oracle User for CDC Connector <${orausername}> and password <${orapassword}>"
  echo "-> Method for CDC Connector starting reading <${current}>"
  echo "-> CDC Connector will changes from table <${tablename}>"
  echo "***********************************************************"
  echo "Continue with press ENTER..."
  read WAIT
  }

### **********************************************************
###
###        MENU INSTALLATION
###
### **********************************************************
menu()
{
clear
echo "
  [4m Start Confluent CDC Connector for Oracle Demo: $oraserver:$oraport/$orasid/$orapdbname User: $orausername  [0m

  [4m Start.From  $startfrom with table [0m                                                                                          
  [0m  [6m    $tablename

  [4m Demo-Setups for different Oracle Versions        [0m  
  [7m  [0m   Demo Setup for Oracle DB 11g (not covered yet)
  [7m  [0m   Demo Setup for Oracle DB 12c NON-CDB (not covered yet)
  [7m  [0m   Demo Setup for Oracle DB 12c CDB only (not covered yet)
  [7m  [0m   Demo Setup for Oracle DB 12c PDB (coming soon)
  [7m  [0m   Demo Setup for Oracle DB 18c (not covered yet)       
  [7m  [0m   Demo Setup for Oracle DB 19c NON-CDB (not covered yet)
  [7m  [0m   Demo Setup for Oracle DB 19c CDB only (not covered yet)
  [7m 8[0m   Demo Setup for Oracle DB 19c PDB (to be executed)      
  [7m  [0m   Demo Setup for Oracle DB 21c (not supported yet)    "             
echo "  
  [4m Administration [0m
  [7m r[0m consume from redo log topic
  [7m t[0m consume from table topic for table ${topicname}
  [7m d[0m Delete Confluent Cloud Cluster Setup for this demo
  [7m x[0m Exit This script


"
echo " Auswahl: $NORET"
read install
}


### **********************************************************
### Show CDC Config
### **********************************************************

### **********************************************************
### Run 19c DEMO Setup
### **********************************************************
build19cPDBDemo()
{
  # first create the cluster 
  ${STARTDIR}/01-1_ccloud_cluster.sh
  source ./env-vars
  # Create cdc-connect-standalone.property file
echo "bootstrap.servers=${source_endpoint}
# The converters specify the format of data in Kafka and how to translate it into Connect data. Every Connect user will
# need to configure these based on the format they want their data in when loaded from or stored into Kafka
key.converter=org.apache.kafka.connect.json.JsonConverter
value.converter=org.apache.kafka.connect.json.JsonConverter
# Converter-specific settings can be passed in by prefixing the Converter's setting with the converter you want to apply
# it to
key.converter.schemas.enable=false
value.converter.schemas.enable=false
# The internal converter used for offsets and config data is configurable and must be specified, but most users will
# always want to use the built-in default. Offset and config data is never visible outside of Kafka Connect in this format.
internal.key.converter=org.apache.kafka.connect.json.JsonConverter
internal.value.converter=org.apache.kafk

a.connect.json.JsonConverter
internal.key.converter.schemas.enable=false
internal.value.converter.schemas.enable=false
# Store offsets on local filesystem
offset.storage.file.filename=/tmp/connect.offsets
# Flush much faster than normal, which is useful for testing/debugging
offset.flush.interval.ms=10000
ssl.endpoint.identification.algorithm=https
sasl.mechanism=PLAIN
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username=\"${sourcekey}\" password=\"${sourcesecret}\";
security.protocol=SASL_SSL

consumer.ssl.endpoint.identification.algorithm=https
consumer.sasl.mechanism=PLAIN
consumer.sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username=\"${sourcekey}\" password=\"${sourcesecret}\";
consumer.security.protocol=SASL_SSL

producer.ssl.endpoint.identification.algorithm=https
producer.sasl.mechanism=PLAIN
producer.sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username=\"${sourcekey}\" password=\"${sourcesecret}\";
producer.security.protocol=SASL_SSL

# Set to a list of filesystem paths separated by commas (,) to enable class loading isolation for plugins
# (connectors, converters, transformations).
plugin.path=${pluginpath}
# Confluent Schema Registry for Kafka Connect
value.converter=io.confluent.connect.avro.AvroConverter
value.converter.basic.auth.credentials.source=USER_INFO
value.converter.schema.registry.basic.auth.user.info=${srkey}:${srsecret}
value.converter.schema.registry.url=${srurl}
# Telemetry
metric.reporters=io.confluent.telemetry.reporter.TelemetryReporter
confluent.telemetry.enabled=true
confluent.telemetry.api.key=${healthpluskey}
confluent.telemetry.api.secret=${healthplussecret}" > ${STARTDIR}/cdc-connect-standalone.properties

# Create Connector config file
echo "name=Ora19cCDC_1
connector.class=io.confluent.connect.oracle.cdc.OracleCdcSourceConnector
tasks.max=2
key.converter=io.confluent.connect.avro.AvroConverter
key.converter.schema.registry.url=${srurl}
key.converter.basic.auth.user.info=${srkey}:${srsecret}
key.converter.basic.auth.credentials.source=USER_INFO
value.converter=io.confluent.connect.avro.AvroConverter
value.converter.schema.registry.url=${srurl}
value.converter.basic.auth.user.info=${srkey}:${srsecret}
value.converter.basic.auth.credentials.source=USER_INFO
confluent.topic.ssl.endpoint.identification.algorithm=https
confluent.topic.sasl.mechanism=PLAIN
confluent.topic.bootstrap.servers=${source_endpoint}
confluent.topic.sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username=\"${sourcekey}\" password=\"${sourcesecret}\";
confluent.topic.security.protocol=SASL_SSL
confluent.topic.replication.factor=3
topic.creation.groups=redo
topic.creation.redo.include=redo-log-topic-1
topic.creation.redo.replication.factor=3
topic.creation.redo.partitions=1
topic.creation.redo.cleanup.policy=delete
topic.creation.redo.retention.ms=1209600000
topic.creation.default.replication.factor=3
topic.creation.default.partitions=1
topic.creation.default.cleanup.policy=compact
oracle.server=${oraserver}
oracle.port=${oraport}
oracle.sid=${orasid}
oracle.pdb.name=${orapdbname}
oracle.username=${orausername}
oracle.password=${orapassword}
start.from=${startfrom}
redo.log.topic.name=redo-log-topic-1
redo.log.consumer.bootstrap.servers=${source_endpoint}
redo.log.consumer.sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username=\"${sourcekey}\" password=\"${sourcesecret}\";
redo.log.consumer.security.protocol=SASL_SSL
redo.log.consumer.sasl.mechanism=PLAIN
table.inclusion.regex=${tablename}
table.topic.name.template=\${databaseName}.\${schemaName}.\${tableName}
numeric.mapping=best_fit
connection.pool.max.size=20
redo.log.row.fetch.size=1
snapshot.row.fetch.size=1
oracle.dictionary.mode=auto" > ${STARTDIR}/oraclecdc19c-config.properties

  echo "Demo Setup is running"
  echo "Now you can execute the connector"
  echo "$CONFLUENT_HOME/bin/connect-standalone  ./cdc-connect-standalone.properties ./oraclecdc19c-config.properties"
  echo "Check the Status of CDC Connector in a 2nd terminal window"
  echo "curl -s -X GET -H 'Content-Type: application/json' http://localhost:8083/connectors/Ora19cCDC_1/status | jq"
  echo "PRESS Enter to continue..."
  read WAIT
}

### **********************************************************
### Run consume from Redolog 19c DEMO Setup
### **********************************************************
consumeRedo()
{
confluent kafka topic consume -b redo-log-topic-1 --cluster $source_id --environment $environment \
    --api-key $sourcekey --api-secret $sourcesecret \
    --schema-registry-endpoint $srurl  --schema-registry-api-key $srkey --schema-registry-api-secret $srsecret

}
### **********************************************************
### Run consume from Tabletopic 19c DEMO Setup
### **********************************************************
consumeTableTopic()
{
  # Replace [] from ${tablename}
  confluent kafka topic consume -b $topicname --cluster $source_id --environment $environment \
    --api-key $sourcekey --api-secret $sourcesecret \
    --schema-registry-endpoint $srurl  --schema-registry-api-key $srkey --schema-registry-api-secret $srsecret
}

### **********************************************************
### Delete Confluent Cloud Cluster
### **********************************************************
deleteCCloud()
{
  echo "Delete Confluent Cloud Cluster"
  ${STARTDIR}/01-2_delete_ccloud_cluster.sh
}


### **********************************************************
###
### print_ende
###
### **********************************************************
print_ende() 
{
  echo "************************************************************"
  echo "*                                                          *"
  echo "* Start Confluent CDC Connector for Oracle Demo:  END      *" 
  echo "*                                                          *"
  echo "************************************************************"
}

### **********************************************************
###
###   Start SETUP
###
### **********************************************************
#
### **********************************************************
###       Installation: Test echo works
### **********************************************************
# Look for good echo:
test -f /bin/echo
[ $? = 0 ] && ECHO=/bin/echo

test -f /usr/bin/echo
[ $? = 0 ] && ECHO=/usr/bin/echo

# Test if echo knows "\c":
if [ `$ECHO "\c" | wc -c` = 0 ]
then
  NORET="\c"
else
  NORET=""
fi

clear

echo "************************************************************"
echo "*                                                          *"
echo "*  Start                                                   *"
echo "*                                                          *"
echo "************************************************************"

###############################################################
##                I N I T I A L I S I E R E                   #
###############################################################
initialisiere

umask 022
echo ""

### **********************************************************
###
###        M E N U
###
### **********************************************************


while [ "$install" != "X" -o "$install" != "x" ]
	do
  	cd ${STARTDIR}
		menu
		if [ "$install" = "x"  -o  "$install" = "X" ]
		then    
		  echo "End script execution."
		  print_ende
		  exit 0
		elif [ "$install" = "r" -o "$install" = "R" ]
		then
                   clear   
                   consumeRedo
		elif [ "$install" = "t" -o "$install" = "T" ]
		then
                   clear   
                   consumeTableTopic
		elif [ "$install" = "d" -o "$install" = "D" ]
		then
                   clear   
                   deleteCCloud            
 		elif [ "$install" = "8" ]
		then    
                   clear  
                   build19cPDBDemo
		fi
	done
  print_ende
  exit 0  