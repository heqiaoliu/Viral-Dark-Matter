function isTTChartBlock = is_truth_table_chart_block(blockH)

% Copyright 2005 The MathWorks, Inc.

isTTChartBlock =0;
chartId = block2chart(blockH);
if(~isempty(chartId))
    isTTChartBlock = is_truth_table_chart(chartId);
end
