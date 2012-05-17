function updateprops(h, eventData)
%UPDATEPROPS Update phantom properties each time a dynamic property is added or removed.  

%   Author(s): V. Pellissier
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/22 19:00:01 $

p = propstoadd(h.filterquantizer);
for i=1:length(p),
    pParent = findprop(h,p{i});
    pChild = findprop(h.filterquantizer,p{i});
    pParent.AccessFlags.PublicSet = pChild.AccessFlags.PublicSet;
end

% [EOF]
