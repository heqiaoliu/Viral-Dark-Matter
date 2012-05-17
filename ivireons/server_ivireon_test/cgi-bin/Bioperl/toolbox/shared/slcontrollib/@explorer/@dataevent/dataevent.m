function this = dataevent(eventSrc, propertyName, oldValue, newValue)
% DATAEVENT  Subclass of EVENTDATA to handle string-valued event data.
%
% explorer.dataevent(eventSrc, propertyName, oldValue, newValue)

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2007/12/14 15:01:19 $

% Create class instance
cls = 'explorer.node';
if isa(eventSrc, cls)
  this = explorer.dataevent(eventSrc, 'PropertyChange');
else
  ctrlMsgUtils.error( 'SLControllib:explorer:InvalidArgumentType', 'EVENTSRC', cls );
end

% Assign data
this.propertyName = propertyName;
this.oldValue     = oldValue;
this.newValue     = newValue;
