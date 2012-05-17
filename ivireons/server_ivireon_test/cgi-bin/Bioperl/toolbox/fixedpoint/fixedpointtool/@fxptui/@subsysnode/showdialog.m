function showdialog(h)
%SHOWDIALOG   

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 20:01:35 $

daobj = h.daobject;
if(~isempty(daobj))
  if(daobj.isMasked)
    open_system(daobj.getFullName, 'mask');
  else
    open_system(daobj.getFullName, 'parameter');
  end
end

% [EOF]
