 function metricGroupEnableCallback(this, metricName)

%   Copyright 2009 The MathWorks, Inc.


    this.m_metricGroupVisible.(metricName) = ~this.m_metricGroupVisible.(metricName); 
