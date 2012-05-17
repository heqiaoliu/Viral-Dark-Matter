function cb_highlightclear(h)
%CB_HIGHLIGHTCLEAR <short description>
%   OUT = CB_HIGHLIGHTCLEAR(ARGS) <long description>

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/17 21:49:13 $

me =  fxptui.explorer;
bd = me.getRoot;
mdl = bd.daobject;
if(~isa(mdl, 'Simulink.BlockDiagram'))
	return;
end
mdl.hilite('off');

% [EOF]
