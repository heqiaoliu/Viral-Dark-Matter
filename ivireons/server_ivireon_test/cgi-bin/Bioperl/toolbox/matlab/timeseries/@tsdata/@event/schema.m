function schema
%SCHEMA Defines properties for the @event class.

%   Author(s): James G. Owen
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2005/06/27 22:52:41 $
 
% Register class 
p = findpackage('tsdata');
c = schema.class(p,'event');

% Value object
c.Handle = 'off';

% Public properties

% User-assigned detailed information for this event
schema.prop(c,'EventData','MATLAB array');

% User-assigned the name of events. Note: events with the same “name” can
% occur many times 
schema.prop(c,'Name','string');

% "Time defines" the position of the event in time relative
% to the "StartDate" (if defined) and expressed in the units specified in
% the "Units" property.  
schema.prop(c,'Time','double');
schema.prop(c,'Units','string');
schema.prop(c,'StartDate','string');

