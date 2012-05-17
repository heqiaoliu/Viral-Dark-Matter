function children = getChildren(h)
%GETCHILDREN returns RESULTS

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/11/17 21:50:14 $

me = fxptui.getexplorer;
children = [];
if(~h.isvalid) || isempty(me); return; end
results = me.getresults;
if(isempty(results)); return; end
for i = 1:numel(results)
  child = results(i);
  child.PropertyBag.put('parent', h);
  child = child.getfilteredchild;
  if(~isempty(child) && child.isVisible)
    children = [children child];
  end
end

% EOF
