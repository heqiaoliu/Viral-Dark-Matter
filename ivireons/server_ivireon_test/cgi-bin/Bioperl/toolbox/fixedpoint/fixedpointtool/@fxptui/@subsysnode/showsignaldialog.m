function showsignaldialog(h, port)
%SHOWSIGNALDIALOG

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 20:01:36 $

daobj = h.daobject;
if(~isempty(daobj))
  DAStudio.Dialog(port);
end

% [EOF]
