function b = isremoveable(h)
%ISREMOVEABLE   True if the object is removeable.

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 20:01:24 $

b = false;
me = fxptui.getexplorer;
if(isempty(me) || isempty(me.getRoot) || me.getRoot.isClosing)
	return;
end
if(isempty(me.getRoot.daobject))
	return;
end
if(~strcmpi('stopped', me.getRoot.daobject.SimulationStatus))
	return;
end
b = true;

% [EOF]
