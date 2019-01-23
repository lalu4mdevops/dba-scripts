-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2008 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_files_all.sql                                               |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : Reports on all data files, online redo log files, and control   |
-- |            files within the database.                                      |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET LINESIZE 160
SET PAGESIZE 9999
SET VERIFY   OFF

COLUMN tablespace      FORMAT a29                  HEADING 'Tablespace Name'
COLUMN filename        FORMAT a64                  HEADING 'Filename'
COLUMN filesize        FORMAT 999,999,999,999,999  HEADING 'File Size'
COLUMN autoextensible  FORMAT a4                   HEADING 'Auto'
COLUMN increment_by    FORMAT 999,999,999          HEADING 'Next'
COLUMN maxbytes        FORMAT 99,999,999,999       HEADING 'Max'

BREAK ON report
COMPUTE SUM OF filesize  ON report

SELECT /*+ ordered */
    d.tablespace_name                     tablespace
  , d.file_name                           filename
  , d.bytes                               filesize
  , d.autoextensible                      autoextensible
  , d.increment_by * e.value              increment_by
  , d.maxbytes                            maxbytes
FROM
    sys.dba_data_files d
  , v$datafile v
  , (SELECT value
     FROM v$parameter 
     WHERE name = 'db_block_size') e
WHERE
  (d.file_name = v.name)
UNION
SELECT
    d.tablespace_name                     tablespace 
  , d.file_name                           filename
  , d.bytes                               filesize
  , d.autoextensible                      autoextensible
  , d.increment_by * e.value              increment_by
  , d.maxbytes                            maxbytes
FROM
    sys.dba_temp_files d
  , (SELECT value
     FROM v$parameter 
     WHERE name = 'db_block_size') e
UNION
SELECT
    '[ ONLINE REDO LOG ]'
  , a.member
  , b.bytes
  , null
  , TO_NUMBER(null)
  , TO_NUMBER(null)
FROM
    v$logfile a
  , v$log b
WHERE
    a.group# = b.group#
UNION
SELECT
    '[ CONTROL FILE    ]'
  , a.name
  , TO_NUMBER(null)
  , null
  , TO_NUMBER(null)
  , TO_NUMBER(null)
FROM
    v$controlfile a
ORDER BY 1,2
/
