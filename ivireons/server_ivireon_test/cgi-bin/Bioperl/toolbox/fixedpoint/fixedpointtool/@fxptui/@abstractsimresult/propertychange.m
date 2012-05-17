function propertychange(h,s,e)
%PROPERTYCHANGE updates result names when any item on its path change name

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/10/08 17:10:55 $

if(~isa(s, 'DAStudio.Object')); return; end
d.Path = h.daobject.getFullName;
d.PathItem = h.PathItem;
%if the path and pathitem haven't changed return
if(isequal(d.Path, h.Path) && isequal(d.PathItem, h.PathItem)); return; end
h.FxptFullName = fxptds.getfxptfullname(d);
h.Path = d.Path;
child = h.getfilteredchild;
if(isempty(child))
  h.Name = h.FxptFullName;
else
  h = child;
end
h.firepropertychange;
h.updatefigures;

% [EOF]
