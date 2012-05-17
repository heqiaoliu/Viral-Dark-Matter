function showsignaldialog(h)
%SHOWSIGNALDIALOG brings up the Signal Properties dialog.

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/04/28 03:15:11 $

if ~isempty(h.outport)
    daobj = h.daobject;
    if(~isempty(daobj))
        DAStudio.Dialog(h.outport);
    end
end
% [EOF]
