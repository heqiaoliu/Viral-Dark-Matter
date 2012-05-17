function [targets transports mexfiles interfaces] = get(h)
% GET
%
    
% Copyright 2003-2006 The MathWorks, Inc.
    
    targets    = {};
    transports = {};
    mexfiles   = {};
    interfaces = {};
    
    if ~ishandle(h)
        return;
    end
    
    targets    = h.targets;
    transports = h.transports;
    mexfiles   = h.mexfiles;
    interfaces = h.interfaces;
    
    return;