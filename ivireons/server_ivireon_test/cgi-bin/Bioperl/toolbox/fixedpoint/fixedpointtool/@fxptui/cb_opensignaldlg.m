function cb_opensignaldlg
%CB_OPENSIGNALDLG opens the Signal Properties dialog for the outport of
%this block

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 19:57:41 $

me =  fxptui.explorer;
selection = me.getlistselection;
if(isa(selection, 'fxptui.abstractobject'))
  selection.showsignaldialog;
end

% [EOF]