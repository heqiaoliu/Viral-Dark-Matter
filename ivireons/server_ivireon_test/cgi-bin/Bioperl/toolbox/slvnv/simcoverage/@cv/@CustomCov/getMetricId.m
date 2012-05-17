function metricenumVal = getMetricId(this)

%   Copyright 1997-2008 The MathWorks, Inc.

metricName  = cvi.MetricRegistry.getDVSupportedMaskTypes(this.m_blkTypeName);
metricenumVal = uint32(cvi.MetricRegistry.getEnum(metricName));
