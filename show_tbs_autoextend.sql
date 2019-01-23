WITH my_ddf AS
    (
        SELECT file_id, tablespace_name, file_name,
               DECODE (autoextensible,
                       'YES', GREATEST (BYTES, maxbytes),
                       BYTES
                      ) mysize,
              DECODE (autoextensible,
                      'YES', CASE
                         WHEN (maxbytes > BYTES)
                            THEN (maxbytes - BYTES)
                         ELSE 0
                      END,
                      0
                     ) growth
         FROM dba_data_files)
SELECT   my_ddf.tablespace_name,
         ROUND (SUM (my_ddf.mysize) / (1024 * 1024)) totsize,
         ROUND (SUM (growth) / (1024 * 1024)) growth,
         ROUND ((SUM (NVL (freebytes, 0))) / (1024 * 1024)) dfs,
         ROUND ((SUM (NVL (freebytes, 0)) + SUM (growth)) / (1024 * 1024)
               ) totfree,
         ROUND (  (SUM (NVL (freebytes, 0)) + SUM (growth))
                 / SUM (my_ddf.mysize)
                 * 100
               ) perc
    FROM my_ddf, (SELECT   file_id, SUM (BYTES) freebytes
                      FROM dba_free_space
                  GROUP BY file_id) dfs
   WHERE my_ddf.file_id = dfs.file_id(+)
         AND my_ddf.tablespace_name NOT LIKE '%UNDOTB%'
GROUP BY my_ddf.tablespace_name
ORDER BY 6 DESC