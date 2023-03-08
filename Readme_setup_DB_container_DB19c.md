# Setup Oracle DB EE 19c docker container with a pluggable database
We are going to prepare our own 19c Oracle Database and run it in a docker container.
First we need to build a 19c DB image
* open docker
* increase docker disk to 96GB
Best is follow the [git repo](https://github.com/steveswinsburg/oracle19c-docker)

Open a terminal and login to docker.
```bash
cd /confluent-cdc-plug-n-play
# login to docker hub
docker login
```
Download oracle 19c `LINUX.X64_193000_db_home.zip` from [here](https://www.oracle.com/database/technologies/oracle19c-linux-downloads.html)
you need to login into Oracle Portal to get this zip 
Build Oracle docker container
```bash
git clone https://github.com/oracle/docker-images.git
# check DBCA template, if the database looks great
vi docker-images/OracleDatabase/SingleInstance/dockerfiles/19.3.0/dbca.rsp.tmpl
# change to totalMemory=4000
# copy downloaded Oracle Install archive into the right right dir used to build the docker image
mv LINUX.X64_193000_db_home.zip docker-images/OracleDatabase/SingleInstance/dockerfiles/19.3.0/LINUX.X64_193000_db_home.zip
ll docker-images/OracleDatabase/SingleInstance/dockerfiles/19.3.0/LINUX.X64_193000_db_home.zip
# Build the Oracle Image
cd docker-images/OracleDatabase/SingleInstance/dockerfiles
./buildContainerImage.sh -v 19.3.0 -e
cd /confluent-cdc-plug-n-pla
# Run the database as container
docker run \
--name oracle19c \
-p 1521:1521 \
-p 5500:5500 \
-e ORACLE_PDB=ORCLPDB1 \
-e ORACLE_PWD=password \
-e ORACLE_MEM=4000 \
-v /opt/oracle/oradata \
-d oracle/database:19.3.0-ee
# The database need around 15 minutes to be up and running
docker ps
```
After a while, the database is connectable via 
* Hostname: localhost
* Port: 1521
* Service Name: ORCLPDB1
* Username: sys
* Password: password
* Role: AS SYSDBA

getting shell into oracleDB container
```bash
docker exec -it oracle19c /bin/bash
# if you see no processes, Oracle is not started
ps -ef | grep ora
sqlplus /nolog
SQL> connect sys/password@ORCLCDB as sysdba
SQL> show pdbs
    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         3 ORCLPDB1                       READ WRITE NO
# If you see two PDBS the Oralce is ready configured      
SQL> exit;   
# check services
lsnrctl status
Service "ORCLCDB" has 1 instance(s).
  Instance "ORCLCDB", status READY, has 1 handler(s) for this service...
Service "ORCLCDBXDB" has 1 instance(s).
  Instance "ORCLCDB", status READY, has 1 handler(s) for this service...
Service "cfdf670cee530d34e053020011ac05f0" has 1 instance(s).
  Instance "ORCLCDB", status READY, has 1 handler(s) for this service...
Service "orclpdb1" has 1 instance(s).
  Instance "ORCLCDB", status READY, has 1 handler(s) for this service...
# ORCLDBC is running and ORCLPDB1 
exit
```

Oracle DB 19c configuration for Confluent Oracle CDC Connector is documented [here](https://docs.confluent.io/kafka-connectors/oracle-cdc/current/prereqs-validation.html#configure-database-user-privileges)

Let's do the database configuration:
```bash
cd ora19c
# setup env
export TNS_ADMIN=/confluent-cdc-plug-n-play/ora19c
export ORACLE_SID=ORCLCDB
cat $TNS_ADMIN/tnsnames.ora
#ORCLCDB=localhost:1521/ORCLCDB
#ORCLPDB1= (DESCRIPTION = (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521))(CONNECT_DATA = (SERVER = DEDICATED) (SERVICE_NAME = ORCLPDB1)))

# Work with DB from your local desktop without logging into container
sqlplus sys/password@ORCLCDB as sysdba
SQL> select instance_name, con_id, version from v$instance;
# better way to where I AM
SQL> select decode(sys_context('USERENV', 'CON_NAME'),'CDB$ROOT',sys_context('USERENV', 'DB_NAME'),sys_context('USERENV', 'CON_NAME')) DB_NAME, 
            decode(sys_context('USERENV','CON_ID'),1,'CDB','PDB') TYPE 
       from DUAL;
SQL> exit
sqlplus sys/password@ORCLPDB1 as sysdba
SQL> select instance_name, con_id, version from v$instance;
SQL> select dbid, con_id, name from v$pdbs;
SQL> alter session set container = ORCLPDB1;
# better way to check
SQL> select decode(sys_context('USERENV', 'CON_NAME'),'CDB$ROOT',sys_context('USERENV', 'DB_NAME'),sys_context('USERENV', 'CON_NAME')) DB_NAME, 
            decode(sys_context('USERENV','CON_ID'),1,'CDB','PDB') TYPE 
       from DUAL;
SQL> exit

# create user and sample table around ordermgmt
sqlplus sys/password@ORCLPDB1 as sysdba
SQL> @scripts/01_create_user.sql
SQL> connect ordermgmt/kafka@ORCLPDB1
sql> @scripts/02_create_schema_datamodel.sql
SQL> exit

# Create CDC User with Roles and privileges for PDB, see [here](https://docs.confluent.io/kafka-connectors/oracle-cdc/current/prereqs-validation.html#multitenant-database-pdb)
sqlplus sys/password@ORCLPDB1 as sysdba
sql> @scripts/07_19c_privs.sql
sql> exit;

# Enable archive log into DB
docker exec -it oracle19c /bin/bash
export ORACLE_SID=ORCLCDB
sqlplus /nolog
sql> CONNECT sys/password AS SYSDBA
-- Turn on Archivelog Mode
sql> shutdown immediate
sql> startup mount
sql> alter database archivelog;
sql> alter database open;
-- Should show "Database log mode: Archive Mode"
sql> archive log list
sql> ALTER SESSION SET CONTAINER=cdb$root;
sql> ALTER DATABASE ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;
sql> ALTER SESSION SET CONTAINER=ORCLPDB1;
sql> ALTER DATABASE ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;
sql> exit;
exit;
```
Database is now up and running and prepared for CDC with the Confluent Connector.

## Doing changes in the DB, so that the connector can catch them
When the connector is running and can do some inserts, updates ect. in Database. Here are some samples:
```bash
# Now, Insert a record into PRODUCTS Table
sqlplus ordermgmt/kafka@ORCLPDB1
# add new product sqlplus ordermgmt/kafka@ORCLPDB1
sql> select count(*) from products;
sql> insert into product_categories(category_id, Category_name) values (4,'CPU');
sql> commit;
sql> Insert into products (PRODUCT_ID,PRODUCT_NAME,DESCRIPTION,STANDARD_COST,LIST_PRICE,CATEGORY_ID) values (999,'Intel DG43RK','CPU:LGA775,Form Factor:Micro ATX,RAM Slots:4,Max RAM:8GB',219.69,289.79,4);
sql> commit;
sql> Insert into products (PRODUCT_ID,PRODUCT_NAME,DESCRIPTION,STANDARD_COST,LIST_PRICE,CATEGORY_ID) values (1000,'Asus VANGUARD B85','CPU:LGA1150,Form Factor:Micro ATX,RAM Slots:4,Max RAM:32GB',258.1,287,4);
sql> commit;
sql> Insert into products (PRODUCT_ID,PRODUCT_NAME,DESCRIPTION,STANDARD_COST,LIST_PRICE,CATEGORY_ID) values (1001,'EVGA Z270 Classified K','CPU:LGA1151,Form Factor:EATX,RAM Slots:4,Max RAM:64GB',234.26,283.98,4.);
sql> commit;
sql> Insert into products (PRODUCT_ID,PRODUCT_NAME,DESCRIPTION,STANDARD_COST,LIST_PRICE,CATEGORY_ID) values (1002,'EVGA Classified','CPU:LGA2011-3,Form Factor:EATX,RAM Slots:8,Max RAM:128GB',240.62,283.98,4);
sql> commit;
sql> update products set LIST_PRICE=199.99 where product_id = 999 and CATEGORY_ID=4;
sql> commit;
sql> update products set LIST_PRICE=399.56 where product_id = 1000 and CATEGORY_ID=4 ;
sql> commit;
sql> update products set LIST_PRICE=700.99 where product_id = 1001 and CATEGORY_ID=4;
sql> commit;
sql> Insert into products (PRODUCT_ID,PRODUCT_NAME,DESCRIPTION,STANDARD_COST,LIST_PRICE,CATEGORY_ID) values (1003,'EVGA Classified','CPU:LGA2011-3,Form Factor:EATX,RAM Slots:8,Max RAM:128GB',240.62,283.98,4);
sql> commit;
sql> begin
  for x in 1008..2008 LOOP
     Insert into products (PRODUCT_ID,PRODUCT_NAME,DESCRIPTION,STANDARD_COST,LIST_PRICE,CATEGORY_ID) values (x,'EVGA Classified','CPU:LGA2011-3,Form Factor:EATX,RAM Slots:8,Max RAM:128GB',240.62,283.98,4);
     commit;
  end loop;
end;
/
sql> exit;
```

Stop the container:
```bash
docker stop oracle19c
docker rm oracle19c
# clean docker completely if you want, 
docker system prune
docker rmi $(docker images -a -q)
docker volume prune
````

[go back](Readme_setup_DB_container.md)