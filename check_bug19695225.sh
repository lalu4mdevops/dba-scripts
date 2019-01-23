#!/bin/sh

MAX_RECORDS_IN_SECTOR=31
# Change this value (preferably less than 25)
ALERT_THRESHOLD=25
FIRST_SEGMAPSECTOR_OFFSET=5
LAST_SEGMAPSECTOR_OFFSET=
GD_SEGMAP_SZE=
NUM_RECORDS_IN_LAST_SEGMAP_SECTOR=
LOGFILE="/tmp/$(echo $(basename ${0/.sh/.log}))"
TMP_11232x_LOGFILE="/tmp/tmp_11232x"
MIN_CELL_VERSION=112230
release_version=`cellcli -e list cell attributes releaseVersion|cut -d \. -f1-5 |  sed -e "s/\.//g"`

printLog()
{
  echo $* >> $LOGFILE
}

getSegmapSize()
{
   if [ $release_version -lt 112331 ]; then
      cellutil -d $device -c primary -s info> $TMP_11232x_LOGFILE
      GD_SEGMAP_SIZE=`strings $TMP_11232x_LOGFILE|grep gdiskSegmentMapSize_|uniq|awk -F': ' '{print $2}'`
   else
      GD_SEGMAP_SIZE=`cellutil -d $device -s info|grep gdiskSegmentMapSize_|uniq|awk -F': ' '{print $2}'`
   fi
}

getLastSegmapSectorOffset()
{
  LAST_SEGMAPSECTOR_OFFSET=$(( $FIRST_SEGMAPSECTOR_OFFSET + $(( $GD_SEGMAP_SIZE - 1 )) ))
}

getNumRecordsInLastSec()
{
   if [ $release_version -lt 112331 ]; then
     cellutil -d  $device -c primary -n ${LAST_SEGMAPSECTOR_OFFSET} > $TMP_11232x_LOGFILE
     NUM_RECORDS_IN_LAST_SEGMAP_SECTOR=`strings $TMP_11232x_LOGFILE|grep numRecords|uniq|awk -F': ' '{print $2}'`
   else
     NUM_RECORDS_IN_LAST_SEGMAP_SECTOR=`cellutil -d  $device -n ${LAST_SEGMAPSECTOR_OFFSET}|grep numRecords|uniq|awk -F': ' '{print $2}'`
   fi
}


#Check if software is patched with bug 19695225 fix
check_for_fix()
{
  dvc=`cellcli -e list celldisk attributes devicePartition where diskType=hardDisk and status=normal|head -1`
  count=`cellutil -d $dvc -s info |grep gdiskSegmentMapSize_|wc -l`
  if [ $count -eq 1 ]; then
    echo "SUCCESS: System contains the fix for bug 19695225"
    exit 0;
  fi
}

cleanup()
{
if [ -e $LOGFILE ]; then
   /bin/rm -f $LOGFILE
fi
if [ -e $TMP_11232x_LOGFILE ]; then
   /bin/rm -f $TMP_11232x_LOGFILE
fi
}

if [ ${release_version} -lt ${MIN_CELL_VERSION} ]; then
   echo "[INFO]: You are currently running very old version of cell software : $release_version.  \
   Please contact support to check if the patch for bug 19695225 is needed for your systems."
   exit 0;
fi

check_for_fix
cleanup

date >> $LOGFILE

celldisks_above_threshold=0

for device in `cellcli -e list celldisk attributes devicePartition where diskType=hardDisk and status=normal`
do
  celldisk=`cellcli -e list celldisk attributes name where devicePartition=\"$device\"`
  getSegmapSize
  getLastSegmapSectorOffset
  getNumRecordsInLastSec
  printLog "Num of records in last segmap sector for `echo $celldisk`: $NUM_RECORDS_IN_LAST_SEGMAP_SECTOR"
  if [ ${NUM_RECORDS_IN_LAST_SEGMAP_SECTOR} -ge $ALERT_THRESHOLD ]; then
     printLog "ALERT: $celldisk is at immediate risk to metadata corruption."
     celldisks_above_threshold=$(( $celldisks_above_threshold + 1 ))
  fi 
done

if [ $celldisks_above_threshold -gt 0 ]; then
   echo "ALERT: One or more celldisks are at immediate risk to metadata \
corruption and data loss due to bug 19695225 caused by a high \
number of CREATE/ALTER GRIDDISK commands. \
See MOS Note 1991445.1 for required actions."
   exit 1;
else
   echo "WARNING: System does not contain the fix for bug 19695225. \
Celldisks are at risk to metadata corruption and data loss \
due to bug 19695225 caused by a high number of CREATE/ALTER \
GRIDDISK commands. See MOS Note 1991445.1 for required actions."
   exit 1;
fi
