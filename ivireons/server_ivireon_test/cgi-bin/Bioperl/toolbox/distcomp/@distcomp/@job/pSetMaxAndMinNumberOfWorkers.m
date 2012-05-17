function pSetMaxAndMinNumberOfWorkers(job, newMin, newMax, whichFirst)
; %#ok Undocumented
%pSetMaxAndMinNumberOfWorkers A short description of the function
%
%  VAL = pSetMaxAndMinNumberOfWorkers(JOB, VAL)

%  Copyright 2007-2008 The MathWorks, Inc.

%  $Revision: 1.1.6.2 $    $Date: 2008/08/26 18:13:23 $ 

VALUE_CHECK = true;
% Use the internal functions to actually set the values.
switch whichFirst
    case 'max'
        job.pSetMaximumNumberOfWorkers(newMax, VALUE_CHECK, newMin);
        job.pSetMinimumNumberOfWorkers(newMin, VALUE_CHECK, newMax);
    case 'min'
        job.pSetMinimumNumberOfWorkers(newMin, VALUE_CHECK, newMax);
        job.pSetMaximumNumberOfWorkers(newMax, VALUE_CHECK, newMin);
    otherwise
        assert(false, 'distcomp:simpleparalleljob:Assertion', ...
            'Invalid whichFirst argument: %s', whichFirst);
end