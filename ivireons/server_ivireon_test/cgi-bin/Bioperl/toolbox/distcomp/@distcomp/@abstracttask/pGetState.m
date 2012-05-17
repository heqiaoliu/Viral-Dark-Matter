function val = pGetState(task, val)
; %#ok Undocumented
%pGetState 
%
%  VAL = pGetState(TASK, VAL)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:35:40 $ 

serializer = task.Serializer;

if ~isempty(serializer)
    try
        val = char(serializer.getField(task, 'state'));
    end
end