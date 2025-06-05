To perform this migration please find the steps below:

01) Storage Team to provision the LUNS of the same size [it is important that the size in MB should be exactly matching] on the SAN
02) Storage Team to present the LUNs to both RAC Cluster nodes
03) Linux Team to rescan the Cluster Nodes (both noes) and identify the new LUNs 
04) Linux Team to partition the LUNs (on one node) similar to how it was partitioned for the existing ASM LUNs
05) After this rescan each node and identify the new LUNs and its partitions
06) I would expect them to be of following format on both nodes :

/dev/mapper/asm_data_11p1 
/dev/mapper/asm_data_12p1 
/dev/mapper/asm_data_13p1 
....                      
/dev/mapper/asm_data_20p1 

/dev/mapper/asm_mgt_11p1

/dev/mapper/asm_redo_11p1
/dev/mapper/asm_redo_12p1
/dev/mapper/asm_redo_13p1

07) Ensure the LUNs are available on both nodes and crosscheck the names and they should be matching
08) Once the LUNS are available on both nodes, create ASMLib disks on the first node as **root**:

**NOTE**: Ensure you are using only the partitions (e.g: Use asm_data_11p1 not asm_data_11)

/etc/init.d/oracleasm createdisk ASMDISK11 /dev/mapper/asm_data_11p1
/etc/init.d/oracleasm createdisk ASMDISK12 /dev/mapper/asm_data_12p1
/etc/init.d/oracleasm createdisk ASMDISK13 /dev/mapper/asm_data_13p1
/etc/init.d/oracleasm createdisk ASMDISK14 /dev/mapper/asm_data_14p1
/etc/init.d/oracleasm createdisk ASMDISK15 /dev/mapper/asm_data_15p1
/etc/init.d/oracleasm createdisk ASMDISK16 /dev/mapper/asm_data_16p1
/etc/init.d/oracleasm createdisk ASMDISK17 /dev/mapper/asm_data_17p1
/etc/init.d/oracleasm createdisk ASMDISK18 /dev/mapper/asm_data_18p1
/etc/init.d/oracleasm createdisk ASMDISK19 /dev/mapper/asm_data_19p1
/etc/init.d/oracleasm createdisk ASMDISK20 /dev/mapper/asm_data_20p1

/etc/init.d/oracleasm createdisk MGMT11 /dev/mapper/asm_mgt_11p1
/etc/init.d/oracleasm createdisk REDO11 /dev/mapper/asm_redo_11p1
/etc/init.d/oracleasm createdisk REDO12 /dev/mapper/asm_redo_12p1
/etc/init.d/oracleasm createdisk REDO13 /dev/mapper/asm_redo_13p1

09) Ensure you are able to see them (on first node) under /dev/oracleasm/disks path also its listing using oracleasm command:

/etc/init.d/oracleasm listdisks
ls -l /dev/oracleasm/disks

10) On the second node, rescan the disks using ASMLib as *root*:

/etc/init.d/oracleasm scandisks 

11) Ensure you are able to see them on second node as well:

/etc/init.d/oracleasm listdisks
ls -l /dev/oracleasm/disks

12) Once the ASMLib disks are available on each node, login to ASM instance and run below query and make sure you see them (new disks) in V$ASM_DISK with header_status as PROVISIONED and mount_status as CLOSED:

col compatibility for a10
col database_compatibility for a10
set lines 900 pages 900
col name for a20
col path for a40
select group_number GROUP#,name,allocation_unit_size au_size,state,type,round(total_mb/1024,2) total_gb,round(free_mb/1024,2) free_gb,compatibility,database_compatibility,voting_files
from v$asm_diskgroup order by group_number;
select group_number GROUP#,disk_number DISK#,name,header_status,mount_status,state,round(os_mb/1024,2) os_gb,round(total_mb/1024,2) total_gb,round(free_mb/1024,2) free_gb,path,substr(library,1,20) library,voting_file v  
from v$asm_disk order by group_number,disk_number;

13) Once each node has all the newly created disks available in V$ASM_DISK, please add them to ASM diskgroups (perform only from first node):

*NOTE*: We explicitly make rebalance power 0 so that we don't start an immediate rebalance. We will later perform rebalance in another step.

connect / as sysasm
-- MGMT diskgroup
alter diskgroup MGMT add disk '/dev/oracleasm/disks/MGMT11' rebalance power 0;

-- REDO1 diskgroup
alter diskgroup REDO1 add disk '/dev/oracleasm/disks/REDO11' rebalance power 0;
alter diskgroup REDO1 add disk '/dev/oracleasm/disks/REDO12' rebalance power 0;
alter diskgroup REDO1 add disk '/dev/oracleasm/disks/REDO13' rebalance power 0;

-- DATA1 diskgroup
alter diskgroup DATA1 add disk '/dev/oracleasm/disks/ASMDISK11' rebalance power 0;
alter diskgroup DATA1 add disk '/dev/oracleasm/disks/ASMDISK12' rebalance power 0;
alter diskgroup DATA1 add disk '/dev/oracleasm/disks/ASMDISK13' rebalance power 0;
alter diskgroup DATA1 add disk '/dev/oracleasm/disks/ASMDISK14' rebalance power 0;
alter diskgroup DATA1 add disk '/dev/oracleasm/disks/ASMDISK15' rebalance power 0;
alter diskgroup DATA1 add disk '/dev/oracleasm/disks/ASMDISK16' rebalance power 0;
alter diskgroup DATA1 add disk '/dev/oracleasm/disks/ASMDISK17' rebalance power 0;
alter diskgroup DATA1 add disk '/dev/oracleasm/disks/ASMDISK18' rebalance power 0;
alter diskgroup DATA1 add disk '/dev/oracleasm/disks/ASMDISK19' rebalance power 0;
alter diskgroup DATA1 add disk '/dev/oracleasm/disks/ASMDISK20' rebalance power 0;

14) Check the second node with query given in Step-12 and verify the newly added disks are correctly reflected on each diskgroup. 
15) Now drop the existing disks with (from first node only):

-- MGMT diskgroup
alter diskgroup MGMT drop disk MGMT_0000 rebalance power 0;

-- REDO1 diskgroup
alter diskgroup REDO1 drop disk REDO1_0000 rebalance power 0;
alter diskgroup REDO1 drop disk REDO1_0001 rebalance power 0;
alter diskgroup REDO1 drop disk REDO1_0002 rebalance power 0;

-- DATA1 diskgroup
alter diskgroup DATA1 drop disk DATA1_0000 rebalance power 0;
alter diskgroup DATA1 drop disk DATA1_0001 rebalance power 0;
alter diskgroup DATA1 drop disk DATA1_0002 rebalance power 0;
alter diskgroup DATA1 drop disk DATA1_0003 rebalance power 0;
alter diskgroup DATA1 drop disk DATA1_0004 rebalance power 0;
alter diskgroup DATA1 drop disk DATA1_0005 rebalance power 0;
alter diskgroup DATA1 drop disk DATA1_0006 rebalance power 0;
alter diskgroup DATA1 drop disk DATA1_0007 rebalance power 0;
alter diskgroup DATA1 drop disk DATA1_0008 rebalance power 0;
alter diskgroup DATA1 drop disk DATA1_0009 rebalance power 0;

16) Now perform rebalance one by one (first node):

-- MGMT diskgroup
alter diskgroup MGMT rebalance power 2;

-- REDO1 diskgroup
alter diskgroup REDO1 rebalance power 3;

-- DATA1 diskgroup
alter diskgroup DATA1 rebalance power 5;

17) Verify below view to see if the rebalance is completed (once its completed you will not see any output for below query):

select * from v$asm_operation;

18) Once the rebalance is completed, please run the query in Step-12 and see all the old disks are marked as header_status FORMER and mount_status CLOSED
19) You can keep them for few days before removing. Now all the ASM diskgroups are migrated to the new SAN. 

