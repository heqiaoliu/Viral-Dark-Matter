function add(h, sysTargFile, transport, mexfile, interface)
% ADD
%
    
% Copyright 2003-2006 The MathWorks, Inc.
    
    if ~ishandle(h)
        return;
    end
    
    h.targets   {end+1} = sysTargFile;
    h.transports{end+1} = transport;
    h.mexfiles  {end+1} = mexfile;
    h.interfaces{end+1} = interface;
    
    return;