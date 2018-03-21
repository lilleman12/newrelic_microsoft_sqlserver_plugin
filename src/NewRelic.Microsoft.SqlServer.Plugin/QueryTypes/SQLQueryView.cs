using NewRelic.Microsoft.SqlServer.Plugin.Core;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace NewRelic.Microsoft.SqlServer.Plugin.QueryTypes
{
    [SqlServerQuery("SQLQueryView.sql", "SqlQuery", QueryName = "SQL Querys", Enabled = true)]
    public class SQLQueryView
    {
        [Metric(MetricValueType = MetricValueType.Value, Units = "ms")]
        public long AverageQueryTime { get; set; }

        [Metric(MetricValueType = MetricValueType.Value, Units = "ms")]
        public long TotalQuerysTime { get; set; }

        [Metric(MetricValueType = MetricValueType.Value, Units = "querys")]
        public long NumberOfQuerys { get; set; }

        [Metric(MetricValueType = MetricValueType.Value, Units = "ms")]
        public long Latency { get; set; }

        [Metric(MetricValueType = MetricValueType.Value, Units = "ms")]
        public long ReadLatency { get; set; }

        [Metric(MetricValueType = MetricValueType.Value, Units = "ms")]
        public long WriteLatency { get; set; }



        public override string ToString()
        {
            return string.Format("AverageQueryTime: {0},\t" +
                                 "TotalQuerysTime: {1},\t" +
                                 "NumberOfQuerys: {2}",
                                 "Latency: {3}",
                                 "ReadLatency: {4}",
                                 "WriteLatency: {5}",
                                 AverageQueryTime, TotalQuerysTime, NumberOfQuerys, Latency, ReadLatency, WriteLatency);
        }
    }
}
