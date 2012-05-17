function varargout = getCurrentSystem(newSystem)
%getCurrentSystem Returns the current system in Simulink
%   getCurrentSystem Returns the current system in Simulink regardless of
%   whether we are calling from an S-Function callback.  This function must
%   be called at least once in a MATLAB session before being used in an
%   S-Function callback.
%
%   This can return the wrong system when all of the follow occurs:
%   1) From an HG callback
%   2) The first time in a MATLAB session
%   3) MATLAB is in the callback to an MATLAB file S-Function
%
%   This will appear to return the wrong system when a new model is loaded,
%   however, as no lines/blocks were actually selected, it is correct to
%   point at the old system.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2010/01/25 22:46:19 $

persistent CurrentObjectChangedListener;
persistent system;

if isempty(CurrentObjectChangedListener)
    d = DAStudio.EventDispatcher;
    CurrentObjectChangedListener = ...
        handle.listener(d, 'CurrentObjectChangedEvent', @(h, ev) lclUpdate(ev));
end

if nargin > 0
    system = newSystem;
end

if nargout > 0
    if isempty(system)
        system = gcs;
    end
    varargout = {system};
end

% -------------------------------------------------------------------------
    function lclUpdate(eventData)
        
        system = get(eventData.Source, 'Path');
    end
end

% [EOF]
