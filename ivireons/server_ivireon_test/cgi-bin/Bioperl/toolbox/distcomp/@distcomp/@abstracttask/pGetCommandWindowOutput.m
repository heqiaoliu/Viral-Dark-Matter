function val = pGetCommandWindowOutput(task, val)
; %#ok Undocumented
%pGetCommandWindowOutput 
%
%  VAL = pGetCommandWindowOutput(TASK, VAL)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:35:28 $ 

serializer = task.Serializer;

if ~isempty(serializer)
    try
        val = serializer.getField(task, 'commandwindowoutput');
    end
end