function cb_openblkdlg
%CB_OPENBLKDLG opens selected model

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 19:57:40 $

me =  fxptui.explorer;
selection = me.getlistselection;
if(isa(selection, 'fxptui.abstractresult'))
  selection.showdialog;
end

% [EOF]