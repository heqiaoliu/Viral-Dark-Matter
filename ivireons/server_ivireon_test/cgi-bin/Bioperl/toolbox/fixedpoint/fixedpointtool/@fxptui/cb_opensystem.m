function cb_opensystem
%CB_OPENSYSTEM opens selected model/system

%   Author(s): G. Taillefer
%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/06/20 07:53:56 $

me =  fxptui.explorer;
bd = me.getRoot;
mdl = bd.daobject;
if(~isa(mdl, 'Simulink.BlockDiagram'))
	return;
end
mdl.hilite('off');
selection = me.imme.getCurrentTreeNode;
% Call the view method so that FPT's open action (from the context menu)
% has the same behavior as ME
selection.view;

% [EOF]