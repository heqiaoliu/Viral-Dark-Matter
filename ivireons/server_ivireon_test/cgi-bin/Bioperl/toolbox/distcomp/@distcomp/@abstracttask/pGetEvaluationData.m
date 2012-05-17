function [fcn, nOut, args] = pGetEvaluationData(task)
; %#ok Undocumented
%pGetEvaluationData
%
%  [FUN, NOUT, ARGS] = pGetEvaluationData(TASK)

%  Copyright 2006-2008 The MathWorks, Inc.

%  $Revision: 1.1.6.3 $    $Date: 2008/05/05 21:35:47 $

serializer = task.Serializer;
try
    values = serializer.getFields(task, {'taskfunction' 'nargout' 'argsin'});
catch err
    error('distcomp:task:CorruptData', ...
        'Unable to read the task evaluation data from storage.\nNested error :%s', err.message);
end
fcn  = values{1};
nOut = values{2};
args = values{3};
