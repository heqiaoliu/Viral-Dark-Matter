function storage = pReturnStorage(job);
; %#ok Undocumented
%pReturnStorage 
%
%  STOARGE = PRETURNSTORAGE(JOB)

% Copyright 2005-2006 The MathWorks, Inc.

serializer = job.Serializer;
if ~isempty(serializer)
    storage = serializer.Storage;
else
    storage = [];
end