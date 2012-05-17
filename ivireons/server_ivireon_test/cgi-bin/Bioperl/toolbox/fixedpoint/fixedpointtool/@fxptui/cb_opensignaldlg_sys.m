function cb_opensignaldlg_sys(idx)
%CB_OPENSIGNALDLG_SYS opens the Signal Properties dialog for the outport of
%this block

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 19:57:42 $

me =  fxptui.explorer;
selection = me.imme.getCurrentTreeNode;
if(isa(selection, 'fxptui.subsysnode'))
  outports = get_param(selection.daobject.PortHandles.Outport, 'Object');
  port = outports(idx);
  if(iscell(port)); port = port{:}; end  
  DAStudio.Dialog(port);
end

% [EOF]