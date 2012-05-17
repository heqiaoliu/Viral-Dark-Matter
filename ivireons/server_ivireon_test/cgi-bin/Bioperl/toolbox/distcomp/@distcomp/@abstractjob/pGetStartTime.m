function val = pGetStartTime(job, val)
; %#ok Undocumented
%pGetStartTime 
%
%  VAL = pGetStartTime(JOB, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision $    $Date: 2006/06/27 22:34:06 $ 

serializer = job.Serializer;

if ~isempty(serializer)
    try
        val = char(serializer.getField(job, 'starttime'));
    end
end