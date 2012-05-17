function val = pGetState(job, val)
; %#ok Undocumented
%pGetState 
%
%  VAL = pGetState(JOB, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision $    $Date: 2006/06/27 22:34:07 $ 

serializer = job.Serializer;

if ~isempty(serializer)
    try
        val = char(serializer.getField(job, 'state'));
        % This field might be better retrieved using the scheduler
        % therefore we will look at deferring the call to the actual
        % scheduler being used
        scheduler = job.up;
        if isa(scheduler, 'distcomp.abstractscheduler')
            val = scheduler.pGetJobState(job, val);
        end
    end
end