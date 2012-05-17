function currentSldvData = setVersionToCurrent(sldvData)

%   Copyright 2008-2010 The MathWorks, Inc.
    currentSldvData = sldvData;
    try
        sldv_ver= ver('sldv');
    catch Mex %#ok<NASGU>
        sldv_ver = [];
    end     
    if ~isempty(sldv_ver)
        currentSldvData.Version = sldv_ver(1).Version;
    end
end