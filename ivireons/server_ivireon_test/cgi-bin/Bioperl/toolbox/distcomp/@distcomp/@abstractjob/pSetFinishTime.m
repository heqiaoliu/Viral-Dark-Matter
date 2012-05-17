function val = pSetFinishTime(job, val)
; %#ok Undocumented
%pSetFinishTime 
%
%  VAL = pSetFinishTime(JOB, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision $    $Date: 2006/06/27 22:34:21 $ 

serializer = job.Serializer;

if ~isempty(serializer)
    try
        serializer.putField(job, 'finishtime', val);
    end
end
% Store nothing
val = '';