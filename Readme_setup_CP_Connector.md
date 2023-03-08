# Setup on local Desktop to use Oracle CDC Connector

* Install Confluent Platform latest version
    * Java Version 11
    * Confluent Platform Current Version (7.3.2)
* Install Confluent Oracel CDC Source Connector
* Install Confluent Cli

## Installation
 Choose where you want to install the software in my case under `/software`
Install Java from [here](https://docs.oracle.com/en/java/javase/11/install/installation-jdk-macos.html#GUID-2FE451B0-9572-4E38-A1A5-568B77B146DE)
Install Confluent Platform
```bash
cd ~/software
curl -O https://packages.confluent.io/archive/7.3/confluent-7.3.2.tar.gz
tar xzf confluent-7.3.2.tar.gz
rm confluent-7.3.2.tar.gz
# Install Confluent cli v3..4
curl -sL --http1.1 https://cnfl.io/cli | sh -s -- latest

# Set env parameters
export CONFLUENT_HOME=/Users/cmutzlitz/software/confluent
export CONFLUENT_CONFIG=$CONFLUENT_HOME/etc/kafka
export PATH=$CONFLUENT_HOME/bin:~/software/bin:$PATH
export JAVA_HOME=`/usr/libexec/java_home -v 11`

# Install Connector v2.3.2 from here https://www.confluent.io/hub/confluentinc/kafka-connect-oracle-cdc
# I always install connectors in /software/confluent/share/connector
confluent-hub install confluentinc/kafka-connect-oracle-cdc:2.3.2
#The component can be installed in any of the following Confluent Platform installations: 
#  1. /software/confluent (based on $CONFLUENT_HOME) 
#  2. /software/confluent (where this tool is installed) 
#Choose one of these to continue the installation (1-2): 1
#Do you want to install this into /software/confluent/share/confluent-hub-components? (yN) n
#
#Specify installation directory: /software/confluent/share/java/connector
# 
#Component's license: 
#Confluent Software Evaluation License 
#https://www.confluent.io/software-evaluation-license 
#I agree to the software license agreement (yN) y

#Downloading component Kafka Connect OracleCDC Connector 2.3.2, provided by Confluent, Inc. from Confluent Hub and installing into /Users/cmutzlitz/software/confluent/share/java 
#Detected Worker's configs: 
#  1. Standard: /software/confluent/etc/kafka/connect-distributed.properties 
#  2. Standard: /software/confluent/etc/kafka/connect-standalone.properties 
#  3. Standard: /software/confluent/etc/schema-registry/connect-avro-distributed.properties 
#  4. Standard: /software/confluent/etc/schema-registry/connect-avro-standalone.properties 
#Do you want to update all detected configs? (yN) y
#
#Adding installation directory to plugin path in the following files: 
#  /software/confluent/etc/kafka/connect-distributed.properties 
#  /software/confluent/etc/kafka/connect-standalone.properties 
#  /software/confluent/etc/schema-registry/connect-avro-distributed.properties 
#  /software/confluent/etc/schema-registry/connect-avro-standalone.properties 
# 
#Completed 
```
All the Confluent Software we need, should now be installed.

[go back](README.md)
