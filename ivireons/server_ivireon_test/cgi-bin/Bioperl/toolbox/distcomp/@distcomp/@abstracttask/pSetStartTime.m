function val = pSetStartTime(task, val)
; %#ok Undocumented
%pSetStartTime 
%
%  VAL = pSetStartTime(TASK, VAL)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:35:54 $ 

serializer = task.Serializer;

if ~isempty(serializer)
    try
        serializer.putField(task, 'starttime', val);
    end
end
% Store nothing
val = '';