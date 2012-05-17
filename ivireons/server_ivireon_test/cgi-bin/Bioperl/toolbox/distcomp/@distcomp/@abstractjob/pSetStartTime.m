function val = pSetStartTime(job, val)
; %#ok Undocumented
%pSetStartTime 
%
%  VAL = pSetStartTime(JOB, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision $    $Date: 2006/06/27 22:34:27 $ 

serializer = job.Serializer;

if ~isempty(serializer)
    try
        serializer.putField(job, 'starttime', val);
    end
end
% Store nothing
val = '';