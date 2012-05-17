function cb_highlightsystem
%CB_HIGHLIGHTSYSTEM highlights selected system in model

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 19:57:39 $

me =  fxptui.explorer;
selection = me.imme.getCurrentTreeNode;
if(isa(selection, 'fxptui.abstractobject'))
  selection.highlightblock;
end

% [EOF]