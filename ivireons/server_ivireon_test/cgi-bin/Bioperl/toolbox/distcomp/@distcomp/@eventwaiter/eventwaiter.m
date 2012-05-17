function obj = eventwaiter(l, varargin)
; %#ok Undocumented

%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision $  $Date: 2008/03/31 17:07:20 $

% Make sure that the first argument is a listener
if ~isa(l, 'handle.listener')
    error('distcomp:eventwaiter:InvalidArgument', 'The first argument to eventwaiter must be a handle.listener');
end

% Create the object
obj = distcomp.eventwaiter;

% Copy the relevant properties from this listener
listeners = [ ...
    handle.listener(l.Container, l.SourceObject, l.EventType, @eventTriggered);...
    handle.listener(l.SourceObject, 'ObjectBeingDestroyed', @eventTriggered);...
    ];

set(listeners, 'CallbackTarget', obj);

% Store everything 
obj.set('Listeners', listeners, varargin{:});
