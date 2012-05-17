
%   Copyright 2008 The MathWorks, Inc.

function [coveng modelcovId]= getInstance(modelH)

modelcovId = get_param(modelH, 'CoverageId');
topModelcovId = cv('get', modelcovId, '.topModelcovId');
%it can happen during model close
if cv('ishandle', topModelcovId)
    coveng = cv('get', topModelcovId, '.topModelCov');
else
    coveng  = [];
end


