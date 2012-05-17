function setMetricStates(this, metricNames, values)

% Copyright 2009-2010 The MathWorks, Inc.

for idx = 1:numel(metricNames)
    this.(metricNames{idx}) = values(idx);
end
this.m_dlg.refresh;