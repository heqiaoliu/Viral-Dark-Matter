function val = pSetNumberOfOutputArguments(task, val)
; %#ok Undocumented
%pSetNumberOfOutputArguments 
%
%  VAL = pSetNumberOfOutputArguments(TASK, VAL)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:35:52 $ 

serializer = task.Serializer;

if ~isempty(serializer)
    try
        serializer.putField(task, 'nargout', val);
    end
end
% Store nothing
val = 0;