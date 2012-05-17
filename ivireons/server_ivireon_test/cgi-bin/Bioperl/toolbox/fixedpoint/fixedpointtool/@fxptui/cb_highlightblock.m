function cb_highlightblock
%CB_HIGHLIGHTBLOCK highlights selected block in model

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/11/17 21:49:12 $

me =  fxptui.explorer;
selection = me.getlistselection;
if(isa(selection, 'fxptui.abstractobject'))
  selection.highlightblock;
else
    fxptui.showdialog('noselectionhighlight');
end

% [EOF]