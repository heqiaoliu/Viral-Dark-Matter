function val = pSetState(job, val)
; %#ok Undocumented
%pSetState 
%
%  VAL = pSetState(JOB, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision $    $Date: 2006/06/27 22:34:28 $ 

serializer = job.Serializer;

if ~isempty(serializer)
    try
        serializer.putField(job, 'state', val);
    end
end
% Store nothing
val = 'unavailable';