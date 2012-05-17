function val = pSetJobData(job, val)
; %#ok Undocumented
%pSetJobData 
%
%  VAL = pSetJobData(JOB, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision $    $Date: 2006/06/27 22:34:22 $ 

serializer = job.Serializer;

if ~isempty(serializer)
    try
        serializer.putField(job, 'jobdata', val);
    end
end
% Store nothing
val = [];