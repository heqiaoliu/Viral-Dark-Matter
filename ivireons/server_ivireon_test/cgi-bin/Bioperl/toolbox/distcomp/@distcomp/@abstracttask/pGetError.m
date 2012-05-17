function val = pGetErrorMessage(task, val)
; %#ok Undocumented
%pGetErrorMessage 
%
%  VAL = pGetErrorMessage(TASK, VAL)

%  Copyright 2006 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2006/09/27 00:20:47 $ 

serializer = task.Serializer;

if ~isempty(serializer)
    try
        val = serializer.getField(task, 'errorstruct');
    end
end