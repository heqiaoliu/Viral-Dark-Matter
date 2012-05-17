function blkdgm = getbdroot(h)
%GETBDROOT Get the bdroot.


%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/10 21:33:33 $

chart = getchart(h.daobject);
blkdgm = bdroot(chart);

%--------------------------------------------------------------------------
function chart = getchart(obj)
chart = [];
if(~isa(obj, 'DAStudio.Object')); return; end
while(~isa(obj, 'Simulink.BlockDiagram'))
    try
        obj = obj.getParent;
    catch
        return;
    end
end
chart = obj.getFullName;


% [EOF]
