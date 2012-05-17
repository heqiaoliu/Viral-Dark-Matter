function term(modelcovId)

%   Copyright 2008 The MathWorks, Inc.

try
cv('set', modelcovId, '.topModelcovId', 0); 
cv('set', modelcovId, '.refModelcovIds', []);
cv('set', modelcovId, '.topModelCov', []);

catch MEx 
    rethrow(MEx);
end


