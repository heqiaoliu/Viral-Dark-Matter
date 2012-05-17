function cb_plotdiffinfigure
%CB_PLOTINFIGURE   Callback for "Time Series in Figure" action.

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/11/17 21:49:15 $

me = fxptui.getexplorer;
selection = me.getlistselection;
if(isempty(selection))
  fxptui.showdialog('noselection');
  return;
end
active = me.getresults(0, selection.daobject, selection.PathItem);
reference = me.getresults(1, selection.daobject, selection.PathItem);
if(~isempty(active) && active.isplottable && ~isempty(reference) && reference.isplottable)
  active.plotdiffinfigure(reference);
else
  fxptui.showdialog('diffnotplottable');
end

% [EOF]
