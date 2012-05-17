function setmetadata(h, run, name, value)
% SETMETADATA  sets NAME to specified VALUE for specified RUN

%   Author(s): G. Taillefer
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 


if(~isequal(4, nargin))
  error('fixedpoint:fxptds:dataset:setmetadata:notEnoughInputArgs', ...
        'Not enough input arguments. Please specify RUN (double), NAME (double|char) and VALUE (double|char).');
end
if ~h.isSDIEnabled
    runHash = h.simruns.get(run);
    % Could be called by FPA before the run is initialized via the EngineStop
    % listener.
    if ~isempty(runHash)
        metadataHash = h.simruns.get(run).get('metadata');
        metadataHash.put(name, value);
    end
end

% [EOF]
