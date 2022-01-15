##########################
## Check de DG de Arch  ##
##   Standby Database   ##
##                      ##
## Ruben Morais         ##
## 2015-03-17           ##
##########################
#!/bin/ksh

. /home/oracle/envOEM1ADB1

log=/home/oracle/admin/scripts/rman/log/delete_arch.log

recover_dest_space=`sqlplus -SL "/as sysdba" << EOF
set pagesize 0 feedback off verify off heading off echo off
select ceil ( ( (space_used - space_reclaimable ) / space_limit) * 100) pct_used from v\\$recovery_file_dest;
exit;
EOF`


if [[ $recover_dest_space -ge 20 ]]; then
	echo "Warning: FRA_OEM1ADB1 a ${recover_dest_space}%. Limpeza de archives em execucao" > ${log}

	applied_sequence_1=`sqlplus -SL "/as sysdba" <<EOF1
	whenever sqlerror exit sql.sqlcode
	set pagesize 0 feedback off verify off heading off echo off
	select max(sequence#)-20 from v\\$archived_log where applied = 'YES' and REGISTRAR='RFS' and thread#=1;
	lalu
	exit;
	EOF1`

	applied_sequence_2=`sqlplus -SL "/as sysdba" <<EOF2
	whenever sqlerror exit sql.sqlcode
	set pagesize 0 feedback off verify off heading off echo off
	select max(sequence#)-20 from v\\$archived_log where applied = 'YES' and REGISTRAR='RFS' and thread#=2;
	exit;
	EOF2`

	/home/oracle/admin/scripts/rman/remove_arch_stdb.sh

	fi

exit 0
