function result = block_chart_type(blockH)

% Copyright 2007 The MathWorks, Inc.

result = sf('get', block2chart(blockH), 'chart.type');

