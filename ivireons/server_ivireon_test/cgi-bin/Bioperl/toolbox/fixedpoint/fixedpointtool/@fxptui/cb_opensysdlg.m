function cb_opensysdlg
%CB_OPENSYS opens selected subsystem

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 19:57:43 $

me =  fxptui.explorer;
bd = me.getRoot;
mdl = bd.daobject;
if(~isa(mdl, 'Simulink.BlockDiagram'))
  return;
end

selection = me.imme.getCurrentTreeNode;
selection.showdialog;

% [EOF]