function val = pGetMaximumNumberOfWorkers(job, val)
; %#ok Undocumented
%PGETMAXIMUMNUMBEROFWORKERS A short description of the function
%
%  VAL = PGETMAXIMUMNUMBEROFWORKERS(JOB, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:39:00 $ 

serializer = job.Serializer;

if ~isempty(serializer)
    try
        val = serializer.getField(job, 'maxworkers');
    end
end