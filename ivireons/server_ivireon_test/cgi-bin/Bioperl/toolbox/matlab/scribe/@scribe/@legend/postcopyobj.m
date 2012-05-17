function postcopyobj(h,oldh)
%POSTCOPYOBJ Post-process an object created by COPYOBJ

%   Copyright 2005 The MathWorks, Inc.

set(h,'String',get(oldh,'String'))
set(h,'Location','none');
h.init;
methods(h,'update_userdata');
