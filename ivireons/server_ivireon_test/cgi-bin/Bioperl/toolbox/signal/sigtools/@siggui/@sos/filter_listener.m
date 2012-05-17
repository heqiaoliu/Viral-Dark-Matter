function filter_listener(hObj, eventData)
%FILTER_LISTENER Listener to outside filters

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/04/13 00:26:16 $

set(hObj, 'isApplied', 0);

h  = get(hObj, 'Handles');
Hd = get(hObj, 'Filter');

% Only enable the scale popup if we have a df2 structure
if any(strcmpi(class(Hd), {'dfilt.df2', 'dfilt.df2sos'}))
    enabState = 'on';
else,
    enabState = 'off';
end

setenableprop(h.scale, enabState);

% If we already have an SOS filter change the title of the dialog
if isa(Hd, 'dfilt.abstractsos')
    title = 'Order and Scale SOS';
else,
    title = 'Convert to SOS';
end

set(hObj.FigureHandle, 'Name', title);

% [EOF]
