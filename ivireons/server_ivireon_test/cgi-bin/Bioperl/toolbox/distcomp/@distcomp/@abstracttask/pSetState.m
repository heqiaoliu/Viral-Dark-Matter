function val = pSetState(task, val)
; %#ok Undocumented
%pSetState 
%
%  VAL = pSetState(TASK, VAL)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:35:55 $ 

serializer = task.Serializer;

if ~isempty(serializer)
    try
        serializer.putField(task, 'state', val);
    end
end
% Store nothing
val = 'unavailable';