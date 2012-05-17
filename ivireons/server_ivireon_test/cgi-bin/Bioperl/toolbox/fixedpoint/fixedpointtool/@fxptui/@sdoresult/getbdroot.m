function bd = getbdroot(h)
% Get the root model that the Signal Object is used in.

%   Copyright 2008 The MathWorks, Inc.

if ~isempty(h.actualSrcBlk)
  chart = getchart(h.actualSrcBlk{1});
else
  chart = [];
end
bd = bdroot(chart);

%--------------------------------------------------------------------------
function chart = getchart(obj)
chart = [];
if(~isa(obj, 'DAStudio.Object')); return; end
while(~isa(obj, 'Simulink.BlockDiagram'))
    try
        obj = obj.getParent;
    catch e
        return;
    end
end
chart = obj.getFullName;

    
    
