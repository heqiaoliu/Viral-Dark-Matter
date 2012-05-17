function val = pGetFinishTime(task, val)
; %#ok Undocumented
%pGetFinishTime 
%
%  VAL = pGetFinishTime(TASK, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision $    $Date: 2006/06/27 22:35:32 $ 

serializer = task.Serializer;

if ~isempty(serializer)
    try
        val = char(serializer.getField(task, 'finishtime'));
    end
end