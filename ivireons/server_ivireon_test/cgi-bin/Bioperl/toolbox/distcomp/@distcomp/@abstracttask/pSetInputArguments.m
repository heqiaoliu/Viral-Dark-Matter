function val = pSetInputArguments(task, val)
; %#ok Undocumented
%pSetInputArguments 
%
%  VAL = pSetInputArguments(TASK, VAL)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:35:50 $ 

serializer = task.Serializer;

if ~isempty(serializer)
    % Check we have been sent something sensible
    if ~(iscell(val) && (isvector(val) || isempty(val)))
        error('distcomp:simpletask:InvalidProperty','InputArguments must be a vector cell array');
    end
    try
        serializer.putField(task, 'argsin', val);
    end
end
% Store nothing
val = [];