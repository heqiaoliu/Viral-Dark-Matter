function cb_highlightdtgroup
%CB_HIGHLIGHTDTGROUP highlights all blocks that are in the same DTGroup

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/17 21:49:14 $

me =  fxptui.explorer;
selection = me.getlistselection;
if(isa(selection, 'fxptui.abstractobject'))
  mdl = selection.getbdroot;
  run = selection.Run;
  listname = selection.DTGroup;
  fxptui.highlightdtgroup(mdl, run, listname);
else
  fxptui.showdialog('noselectionhighlightdtgroup');
end

% [EOF]