function val = pGetName(task, val)
; %#ok Undocumented
%pGetName 
%
%  val = pGetName(TASK, val)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:35:36 $ 

serializer = task.Serializer;

if ~isempty(serializer)
    try
        val = char(serializer.getField(task, 'name'));
    end
end