function val = pSetErrorMessage(task, val)
; %#ok Undocumented
%pSetErrorMessage 
%
%  VAL = pSetErrorMessage(TASK, VAL)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:35:47 $ 

serializer = task.Serializer;

if ~isempty(serializer)
    try
        serializer.putField(task, 'errormessage', val);
    end
end
% Store nothing
val = '';