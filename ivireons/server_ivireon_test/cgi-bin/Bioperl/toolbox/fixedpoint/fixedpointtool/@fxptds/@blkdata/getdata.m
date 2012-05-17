function d = getdata(h)
%GETDATA

%   Author(s): G. Taillefer
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/17 21:48:48 $

d.Block = h.daobject;
if(isa(h.daobject, 'Stateflow.Data'))
  d.Path = h.daobject.Path;
  d.dataName = h.daobject.Name;
  d.PathItem = '';
else
  d.Path = h.daobject.getFullName;
  d.PathItem = h.pathitem;
end


% [EOF]
