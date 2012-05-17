function val = pGetJobSchedulerData(job, val)
; %#ok Undocumented
%pGetJobSchedulerData 
%
%  VAL = pGetJobSchedulerData(JOB, VAL)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:34:01 $ 

serializer = job.Serializer;

if ~isempty(serializer)
    try
        val = serializer.getField(job, 'jobschedulerdata');
    end
end