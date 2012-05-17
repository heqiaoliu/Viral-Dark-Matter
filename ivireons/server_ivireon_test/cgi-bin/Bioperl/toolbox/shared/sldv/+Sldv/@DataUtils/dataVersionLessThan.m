function out = dataVersionLessThan(sldvData,verstr)

%   Copyright 2010 The MathWorks, Inc.

    dataVersion = sldvData.Version;
    if isempty(dataVersion)
        % sldvData temporarily generated
        out = false;
    else
        toolboxParts = getParts(dataVersion);
        verParts = getParts(verstr);
        out = (sign(toolboxParts - verParts) * [1; .1; .01]) < 0;
    end
end

function parts = getParts(v)
    parts = sscanf(v, '%d.%d.%d')';
    if length(parts) < 3
       parts(3) = 0; % zero-fills to 3 elements
    end
end