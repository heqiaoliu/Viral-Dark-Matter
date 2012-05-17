function bool = isOKtoDelete(h)
%return whether this node is deletable or not.

%  Copyright 2004-2005 The MathWorks, Inc. 
%  $Revision: 1.1.10.1 $ $Date: 2005/07/14 15:25:38 $

if isempty(h.up) || ~ishandle(h.up)
    bool = false;
    return
end

if isequal(h.up,h.getParentNode)
    bool = true;
else
    bool = false;
end
