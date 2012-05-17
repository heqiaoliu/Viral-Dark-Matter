function action = getPropShowAction(h, propName)
%  getPropShowAction
%
%  Returns the show action associated with the message property named
%  propName. The show action defines the DV menu item used to show or
%  hide the property in the DV's message list view.
%
%  Copyright 2009 The MathWorks, Inc.

  
  assoc = h.propShowActions{ ...
    cellfun(@(a) strcmp(a{1}, propName), ...
    h.propShowActions)};
  action = assoc{2};
    
end
