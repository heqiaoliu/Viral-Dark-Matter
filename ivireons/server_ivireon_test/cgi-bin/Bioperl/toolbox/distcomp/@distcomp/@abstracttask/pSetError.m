function val = pSetErrorMessage(task, val)
; %#ok Undocumented
%pSetErrorMessage 
%
%  VAL = pSetErrorMessage(TASK, VAL)

%  Copyright 2006 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2006/09/27 00:20:53 $ 

serializer = task.Serializer;

if ~isempty(serializer)
    try
        serializer.putField(task, 'errorstruct', val);
    end
end
% Store nothing
val = '';