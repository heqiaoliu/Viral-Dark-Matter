function highlightblock(h)
%HIGHLIGHTBLOCK highlight this results daobject in the containing system

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 20:00:23 $

mdlname = h.mdlref.ModelName;
open_system(mdlname);
mdl = get_param(mdlname, 'Object');

if(~isa(mdl, 'Simulink.BlockDiagram'))
	return;
end

mdl.hilite('off');
daobj = h.daobject;
if(~isempty(daobj))
	hilite_system(daobj.getFullName);
end

% [EOF]
