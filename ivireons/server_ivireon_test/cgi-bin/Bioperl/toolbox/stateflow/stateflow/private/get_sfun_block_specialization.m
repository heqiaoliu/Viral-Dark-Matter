function spec = get_sfun_block_specialization(blockH)
%   Copyright 1995-2009 The MathWorks, Inc.

parent = get_param(blockH, 'parent');
hChart = get_param(parent, 'handle');
chartId = block2chart(hChart);
spec = sf('SFunctionSpecialization', chartId, hChart);
