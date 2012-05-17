function val = pSetFunction(task, val)
; %#ok Undocumented
%pSetFunction 
%
%  VAL = pSetFunction(JOB, VAL)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:35:49 $ 

serializer = task.Serializer;

if ~isempty(serializer)
    try
        serializer.putField(task, 'taskfunction', val);
    end
end
% Store nothing
val = [];