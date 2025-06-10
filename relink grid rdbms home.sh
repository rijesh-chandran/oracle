I) To relink the Grid Home please follow below steps from documentation:

The steps would be:

1. Stop the cluster on the RAC node. Make sure no processes are running from RDBMS or GRID HOME:

# as root user
crsctl stop crs -f
ps -ef|egrep 'd.bin|grid|oracle'

2. Unlock the GRID HOME as root user:

cd <GRID_HOME>/crs/install
./rootcrs.sh -unlock 

3. As the Oracle Grid Infrastructure for a cluster owner (grid user):

su - grid
export ORACLE_HOME=<GRID_HOME>
$ORACLE_HOME/bin/relink all

Review the relink log for any errors.

4. Lock the GRID HOME as root user:

cd <GRID_HOME>/rdbms/install/
./rootadd_rdbms.sh
cd <GRID_HOME>/crs/install
./rootcrs.sh -lock

Refer below documentation section:
 
https://docs.oracle.com/en/database/oracle/oracle-database/19/cwsol/relinking-oracle-grid-infrastructure-for-a-cluster-binaries.html

II) Once the GRID HOME is relinked, proceed with relinking ORACLE_HOME (RDBMS HOME). Follow below steps:

1) As the Oracle Home owner (oracle user):

su - oracle
umask 022
export ORACLE_HOME=<RDBMS_HOME>
$ORACLE_HOME/bin/relink all

Review the relink log for any errors.

2) Once this is done you can start the Cluster and RDBMS instances

An example can be see at:

https://www.rackspace.com/blog/relinking-oracle-v18c-grid-infrastructure-for-a-cluster-and-database-binaries
