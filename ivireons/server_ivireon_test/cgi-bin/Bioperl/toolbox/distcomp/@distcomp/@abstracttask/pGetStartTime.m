function val = pGetStartTime(task, val)
; %#ok Undocumented
%pGetStartTime 
%
%  VAL = pGetStartTime(TASK, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:35:39 $ 

serializer = task.Serializer;

if ~isempty(serializer)
    try
        val = char(serializer.getField(task, 'starttime'));
    end
end