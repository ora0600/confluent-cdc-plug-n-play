ALTER SESSION SET CONTAINER=CDB$ROOT;
CREATE ROLE C##CDC_PRIVS;
CREATE USER C##MYUSER IDENTIFIED BY password CONTAINER=ALL;
ALTER USER C##MYUSER QUOTA UNLIMITED ON USERS;
ALTER USER C##MYUSER SET CONTAINER_DATA = (CDB$ROOT, ORCLPDB1) CONTAINER=CURRENT;
GRANT C##CDC_PRIVS to C##MYUSER CONTAINER=ALL;

GRANT CREATE SESSION TO C##CDC_PRIVS CONTAINER=ALL;
GRANT EXECUTE ON SYS.DBMS_LOGMNR TO C##CDC_PRIVS CONTAINER=ALL;
GRANT LOGMINING TO C##CDC_PRIVS CONTAINER=ALL;
GRANT SELECT ON V_$LOGMNR_CONTENTS TO C##CDC_PRIVS CONTAINER=ALL;
GRANT SELECT ON V_$DATABASE TO C##CDC_PRIVS CONTAINER=ALL;
GRANT SELECT ON V_$THREAD TO C##CDC_PRIVS CONTAINER=ALL;
GRANT SELECT ON V_$PARAMETER TO C##CDC_PRIVS CONTAINER=ALL;
GRANT SELECT ON V_$NLS_PARAMETERS TO C##CDC_PRIVS CONTAINER=ALL;
GRANT SELECT ON V_$TIMEZONE_NAMES TO C##CDC_PRIVS CONTAINER=ALL;
GRANT SELECT ON ALL_INDEXES TO C##CDC_PRIVS CONTAINER=ALL;
GRANT SELECT ON ALL_OBJECTS TO C##CDC_PRIVS CONTAINER=ALL;
GRANT SELECT ON ALL_USERS TO C##CDC_PRIVS CONTAINER=ALL;
GRANT SELECT ON ALL_CATALOG TO C##CDC_PRIVS CONTAINER=ALL;
GRANT SELECT ON ALL_CONSTRAINTS TO C##CDC_PRIVS CONTAINER=ALL;
GRANT SELECT ON ALL_CONS_COLUMNS TO C##CDC_PRIVS CONTAINER=ALL;
GRANT SELECT ON ALL_TAB_COLS TO C##CDC_PRIVS CONTAINER=ALL;
GRANT SELECT ON ALL_IND_COLUMNS TO C##CDC_PRIVS CONTAINER=ALL;
GRANT SELECT ON ALL_ENCRYPTED_COLUMNS TO C##CDC_PRIVS CONTAINER=ALL;
GRANT SELECT ON ALL_LOG_GROUPS TO C##CDC_PRIVS CONTAINER=ALL;
GRANT SELECT ON ALL_TAB_PARTITIONS TO C##CDC_PRIVS CONTAINER=ALL;
GRANT SELECT ON SYS.DBA_REGISTRY TO C##CDC_PRIVS CONTAINER=ALL;
GRANT SELECT ON SYS.OBJ$ TO C##CDC_PRIVS CONTAINER=ALL;
GRANT SELECT ON DBA_TABLESPACES TO C##CDC_PRIVS CONTAINER=ALL;
GRANT SELECT ON DBA_OBJECTS TO C##CDC_PRIVS CONTAINER=ALL;
GRANT SELECT ON SYS.ENC$ TO C##CDC_PRIVS CONTAINER=ALL;
GRANT CONNECT TO C##CDC_PRIVS CONTAINER=ALL;
GRANT SELECT ON DBA_PDBS TO C##CDC_PRIVS CONTAINER=ALL;
GRANT SELECT ON CDB_TABLES TO C##CDC_PRIVS CONTAINER=ALL;

ALTER SESSION SET CONTAINER=ORCLPDB1;
GRANT SELECT ON ordermgmt.products TO C##CDC_PRIVS;
#GRANT FLASHBACK ON ordermgmt.products TO C##CDC_PRIVS;

ALTER SESSION SET CONTAINER=CDB$ROOT;
-- The following privileges are required additionally for 19c compared to 12c.
GRANT SELECT ON V_$ARCHIVED_LOG TO C##CDC_PRIVS CONTAINER=ALL;
GRANT SELECT ON V_$LOG TO C##CDC_PRIVS CONTAINER=ALL;
GRANT SELECT ON V_$LOGFILE TO C##CDC_PRIVS CONTAINER=ALL;
GRANT SELECT ON V_$INSTANCE to C##CDC_PRIVS CONTAINER=ALL;