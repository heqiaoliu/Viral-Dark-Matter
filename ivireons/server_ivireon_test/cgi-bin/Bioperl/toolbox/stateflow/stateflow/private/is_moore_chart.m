function result = is_moore_chart(chartId)

% Copyright 2002-2005 The MathWorks, Inc.

    result = ~isempty(sf('find', chartId, 'chart.stateMachineType', 2));
