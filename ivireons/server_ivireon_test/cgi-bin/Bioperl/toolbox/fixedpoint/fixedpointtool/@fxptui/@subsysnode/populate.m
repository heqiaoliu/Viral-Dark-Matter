function populate(h)
%POPULATE

%   Author(s): G. Taillefer
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/07/27 20:12:03 $

%recursively populate hierarchical children
children = h.gethchildren;
if (isempty(children))
  return;
end
n = length(children);
for ci = 1:n
  subsys  = children(ci);
  child = h.addchild(subsys);
  if(~subsys.isMasked)
    populate(child);
  end
end

% [EOF]
