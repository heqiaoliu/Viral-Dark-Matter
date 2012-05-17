function this = dataevent(EventSrc, PropertyName, OldValue, NewValue)
% DATAEVENT  Subclass of EVENTDATA to handle string-valued event data.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2005/12/22 18:55:57 $

% Create object
this = modelpack.dataevent(EventSrc, 'PropertyChange');

% No argument constructor call
if nargin == 0
  return
end

% Assign data
this.PropertyName = PropertyName;
this.OldValue     = OldValue;
this.NewValue     = NewValue;
