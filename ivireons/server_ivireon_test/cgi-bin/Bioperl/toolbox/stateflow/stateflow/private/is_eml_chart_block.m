function isEMLChartBlock = is_eml_chart_block(blockH)

% Copyright 2002 The MathWorks, Inc.

isEMLChartBlock =0;
chartId = block2chart(blockH);
if(~isempty(chartId))
    isEMLChartBlock = is_eml_chart(chartId);
end
