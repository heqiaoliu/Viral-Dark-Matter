function clear(h)
% CLEAR
%
    
% Copyright 2003-2006 The MathWorks, Inc.
    
    if ~ishandle(h)
        return;
    end
    
    h.targets    = {};
    h.transports = {};
    h.mexfiles   = {};
    h.interfaces = {};
    
    return;