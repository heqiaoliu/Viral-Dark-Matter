function val = pSetOutputArguments(task, val)
; %#ok Undocumented
%pSetOutputArguments 
%
%  VAL = pSetOutputArguments(TASK, VAL)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:35:53 $ 

serializer = task.Serializer;

if ~isempty(serializer)
    % Check we have been sent something sensible
    if ~(iscell(val) && (isvector(val) || isempty(val)))
        error('distcomp:simpletask:InvalidProperty','OutputArguments must be a vector cell array');
    end
    try
        serializer.putField(task, 'argsout', val);
    end
end
% Store nothing
val = [];