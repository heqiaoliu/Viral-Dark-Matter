function chartHasNamedDsm = chart_has_named_dsm(blockH,dsmName)

%   Copyright 2006 The MathWorks, Inc.

chartId = block2chart(blockH);

dsmData = sf('find',sf('DataOf',chartId),'data.scope','DATA_STORE_MEMORY_DATA','data.name',dsmName);

chartHasNamedDsm = ~isempty(dsmData);

