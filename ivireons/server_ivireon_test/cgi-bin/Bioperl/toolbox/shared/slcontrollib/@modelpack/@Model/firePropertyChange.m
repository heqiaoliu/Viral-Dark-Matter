function firePropertyChange(this, propertyName, oldValue, newValue)
% FIREPROPERTYCHANGE Fires PropertyChange event to notify listeners
% of property value changes.
%
% PROPERTYNAME  Name of the property that has changed.
% OLDVALUE      Old value of the property.
% NEWVALUE      New value of the property.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2006/09/30 00:23:10 $

% Default arguments
if (nargin < 3 || isempty(oldValue)), oldValue = []; end
if (nargin < 4 || isempty(newValue)), newValue = []; end

% Send event if property value has really changed.
% An empty value always fires the event.
if isempty(oldValue) || isempty(newValue) || ~isequal(oldValue, newValue)
  this.send( 'PropertyChange', ...
             modelpack.dataevent(this, propertyName, oldValue, newValue) );
end
