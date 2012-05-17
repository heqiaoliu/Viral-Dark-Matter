function val = pGetFunction(task, val)
; %#ok Undocumented
%pGetFunction 
%
%  VAL = pGetFunction(JOB, VAL)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:35:33 $ 

serializer = task.Serializer;

if ~isempty(serializer)
    try
        val = serializer.getField(task, 'taskfunction');
    end
end