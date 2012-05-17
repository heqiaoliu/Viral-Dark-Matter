function cb_plothistinfigure
%CB_PLOTHISTINFIGURE   Callback for "Histogram in Figure" action.

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 19:57:46 $

me = fxptui.getexplorer;
selection = me.getlistselection;

if(isempty(selection))
  fxptui.showdialog('noselection');
elseif(selection.isplottable)
  selection.plothistinfigure;
else
  fxptui.showdialog('histnotplottable');
end

% [EOF]
