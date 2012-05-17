function val = pGetID(obj, val)
; %#ok Undocumented
%PGETID A short description of the function
%
%  VAL = PGETID(OBJ, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.3 $    $Date: 2006/06/27 22:38:45 $ 

if ~isempty(obj.UUID)
    val = char(obj.UUID.toString);
end