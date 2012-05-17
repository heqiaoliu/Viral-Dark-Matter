function val = pGetSubmitTime(job, val)
; %#ok Undocumented
%pGetSubmitTime 
%
%  VAL = pGetSubmitTime(JOB, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision $    $Date: 2006/06/27 22:34:09 $ 

serializer = job.Serializer;

if ~isempty(serializer)
    try
        val = char(serializer.getField(job, 'submittime'));
    end
end