function val = pSetCommandWindowOutput(task, val)
; %#ok Undocumented
%pSetCommandWindowOutput 
%
%  VAL = pSetCommandWindowOutput(TASK, VAL)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:35:45 $ 

serializer = task.Serializer;

if ~isempty(serializer)
    try
        serializer.putField(task, 'commandwindowoutput', val);
    end
end
% Store nothing
val = '';