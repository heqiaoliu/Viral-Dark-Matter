function val = pGetFinishTime(job, val)
; %#ok Undocumented
%pGetFinishTime 
%
%  VAL = pGetFinishTime(JOB, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision $    $Date: 2006/06/27 22:33:59 $ 

serializer = job.Serializer;

if ~isempty(serializer)
    try
        val = char(serializer.getField(job, 'finishtime'));
    end
end