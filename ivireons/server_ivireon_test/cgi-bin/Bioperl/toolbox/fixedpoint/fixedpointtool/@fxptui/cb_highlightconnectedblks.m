function cb_highlightconnectedblks
%CB_HIGHLIGHTBLOCK highlights blocks connected to the Signal Object in the model

%   Author(s): V. Srinivasan
%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/11/13 17:56:50 $

me =  fxptui.explorer;
selection = me.getlistselection;
if(isa(selection, 'fxptui.sdoresult'))
  selection.highlightconnectedblks;
else
    fxptui.showdialog('noselectionhighlight');
end

% [EOF]
