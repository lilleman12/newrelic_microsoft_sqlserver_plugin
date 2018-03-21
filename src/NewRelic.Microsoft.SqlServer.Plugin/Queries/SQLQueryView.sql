IF OBJECT_ID('tempdb..#BatchResponses') IS NOT NULL
DROP TABLE #BatchResponses

IF OBJECT_ID('tempdb..#FileStats') IS NOT NULL
DROP TABLE #FileStats

select counter_name, instance_name, cntr_value,1 as iteration
INTO #BatchResponses
FROM  sys.dm_os_performance_counters
WHERE object_name LIKE '%Batch Resp Statistics%'
AND instance_name IN('Elapsed Time:Requests','Elapsed Time:Total(ms)')      

select database_id,file_id, io_stall as stall, num_of_reads, num_of_writes, io_stall_read_ms, io_stall_write_ms, 1 as iteration 
INTO #FileStats
from sys.dm_io_virtual_file_stats(NULL,NULL)

WAITFOR DELAY '00:00:55';

INSERT INTO #BatchResponses
select counter_name, instance_name, cntr_value,2 as iteration
FROM  sys.dm_os_performance_counters
WHERE object_name LIKE '%Batch Resp Statistics%'
AND instance_name IN('Elapsed Time:Requests','Elapsed Time:Total(ms)')      

INSERT INTO #FileStats
select database_id,file_id, io_stall as stall, num_of_reads, num_of_writes, io_stall_read_ms, io_stall_write_ms, 2 as iteration 
from sys.dm_io_virtual_file_stats(NULL,NULL)

                                                                                                               
select	CASE WHEN SUM([count]) = 0 THEN 0 ELSE SUM([time])/SUM([count]) END as AverageQueryTime, 
		SUM([time]) as TotalQuerysTime, 
		SUM([count]) as NumberOfQuerys,
		(select CASE WHEN SUM(((b.num_of_reads+b.num_of_writes)-(a.num_of_reads+a.num_of_writes)))= 0 THEN 0 ELSE SUM((b.stall-a.stall))/SUM(((b.num_of_reads+b.num_of_writes)-(a.num_of_reads+a.num_of_writes))) END as latency
			FROM (Select * FROM #FileStats WHERE iteration=1) a
			LEFT JOIN 
			(
			 SELECT * from #FileStats where iteration=2) b on a.database_id= b.database_id and a.file_id=b.file_id) AS Latency,
		(select CASE WHEN SUM(((b.num_of_reads)-(a.num_of_reads)))= 0 THEN 0 ELSE SUM((b.io_stall_read_ms-a.io_stall_read_ms))/SUM(((b.num_of_reads)-(a.num_of_reads))) END as ReadLatency
			FROM
			(Select * FROM #FileStats WHERE iteration=1) a
			LEFT JOIN 
			(
			 SELECT * from #FileStats where iteration=2) b on a.database_id= b.database_id and a.file_id=b.file_id) AS ReadLatency,
		(select CASE WHEN SUM(((b.num_of_writes)-(a.num_of_writes)))= 0 THEN 0 ELSE SUM((b.io_stall_write_ms-a.io_stall_write_ms))/SUM(((b.num_of_writes)-(a.num_of_writes))) END as WriteLatency
			FROM
			(Select * FROM #FileStats WHERE iteration=1) a
			LEFT JOIN 
			(
			 SELECT * from #FileStats where iteration=2) b on a.database_id= b.database_id and a.file_id=b.file_id) AS WriteLatency
		FROM(
SELECT
	bcount.counter_name,
	ccount.cntr_value - bcount.cntr_value as [count],
	ctime.cntr_value-btime.cntr_value as [time]

FROM
(
     SELECT *
     FROM #BatchResponses
     WHERE instance_name = 'Elapsed Time:Requests' and iteration=1
) bcount
LEFT JOIN
(
     SELECT *
     FROM #BatchResponses
     WHERE instance_name = 'Elapsed Time:Total(ms)'
) btime ON bcount.counter_name = btime.counter_name and btime.iteration=1
LEFT JOIN
(
     SELECT *
     FROM #BatchResponses
     WHERE instance_name = 'Elapsed Time:Requests'
) ccount ON bcount.counter_name = ccount.counter_name and ccount.iteration=2
LEFT JOIN

(
     SELECT *
     FROM #BatchResponses
     WHERE instance_name = 'Elapsed Time:Total(ms)'
) ctime ON ccount.counter_name = ctime.counter_name and ctime.iteration=2
) a

