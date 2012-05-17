function val = pGetJobData(job, val)
; %#ok Undocumented
%pGetJobData 
%
%  VAL = pGetJobData(JOB, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision $    $Date: 2006/06/27 22:34:00 $ 

serializer = job.Serializer;

if ~isempty(serializer)
    try
        val = serializer.getField(job, 'jobdata');
    end
end