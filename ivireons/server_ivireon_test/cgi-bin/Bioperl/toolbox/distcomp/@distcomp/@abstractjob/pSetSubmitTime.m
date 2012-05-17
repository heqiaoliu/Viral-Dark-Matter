function val = pSetSubmitTime(job, val)
; %#ok Undocumented
%pSetSubmitTime 
%
%  VAL = pSetSubmitTime(JOB, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision $    $Date: 2006/06/27 22:34:29 $ 

serializer = job.Serializer;

if ~isempty(serializer)
    try
        serializer.putField(job, 'submittime', val);
    end
end
% Store nothing
val = '';