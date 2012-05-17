function opensystem(h)
%OPENSYSTEM 

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 20:00:50 $

daobj = h.daobject;
if(~isempty(daobj))
  daobj.view
end

% [EOF]
