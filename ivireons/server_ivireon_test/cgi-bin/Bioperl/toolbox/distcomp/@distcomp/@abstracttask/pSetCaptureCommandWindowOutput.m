function val = pSetCaptureCommandWindowOutput(task, val)
; %#ok Undocumented
%pSetCaptureCommandWindowOutput 
%
%  VAL = pSetCaptureCommandWindowOutput(TASK, VAL)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:35:44 $ 

serializer = task.Serializer;

if ~isempty(serializer)
    try
        serializer.putField(task, 'capturecommandwindowoutput', val);
    end
end
% Store nothing
val = false;