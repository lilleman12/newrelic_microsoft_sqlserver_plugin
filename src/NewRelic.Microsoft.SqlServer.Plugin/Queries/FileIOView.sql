-- File I/O View. This data will reset on SQL Server Restart.
-- Size in Bytes good for basic pie or stacked bar chart etc.
-- Data collection nature: Both Cumulative. Needs deltas.

SELECT
	d.name						AS DatabaseName,
	SUM(a.num_of_bytes_read)	AS BytesRead,
	SUM(a.num_of_bytes_written)	AS BytesWritten,
	SUM(a.size_on_disk_bytes)	AS SizeInBytes,
	SUM(a.num_of_reads)			AS NumberOfReads,
	SUM(a.num_of_writes)		AS NumberOfWrites,
	SUM(a.io_stall_read_ms)     AS IoStallReadMs,
	SUM(a.io_stall_write_ms)    AS IoStallWriteMs,
	SUM(a.io_stall)				AS IoStall,
	CASE 
		WHEN SUM([num_of_reads]) = 0 
			THEN 0 
		ELSE (Sum([io_stall_read_ms])/SUM([num_of_reads])) 
	END [ReadLatency],
	CASE 
		WHEN SUM([io_stall_write_ms]) = 0 
			THEN 0 
		ELSE (SUM([io_stall_write_ms])/SUM([num_of_writes])) 
	END [WriteLatency],
	CASE 
		WHEN (SUM([num_of_reads]) = 0 AND SUM([num_of_writes]) = 0)
             THEN 0 
		ELSE (SUM([io_stall])/(SUM([num_of_reads]) + SUM([num_of_writes]))) 
	END [Latency]

FROM sys.databases d
LEFT JOIN sys.dm_io_virtual_file_stats(NULL, NULL) a ON d.database_id = a.database_id
/*{WHERE}*/
GROUP BY d.name
ORDER BY d.name