function setPopupStrings(this, field, objectStrings, popupStrings)
%SETPOPUPSTRINGS Set the PopupStrings
%   setPopupStrings(H, PROPNAME, STRINGS) Set the values in STRINGS into
%   the string of the popup widget controlling the property in PROPNAME.
%
%   setPopupStrings(H, PROPNAME, STRINGS, XLATESTRINGS) Pass in the
%   translated strings XLATESTRINGS and the value of the strings that are
%   set into the object in STRINGS.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/07/14 04:03:38 $

if nargin < 4
    popupStrings = objectStrings;
end

% Get the handle we need to update.
h = get(this, 'Handles');
h = h.(field);

% See if the new string contains the value stored in the object.  It
% should, but this is managed by the concrete class.  Put in safety to
% select the first entry.
value = find(strcmpi(this.(field), objectStrings));
if isempty(value)
    value = 1;
end

% Set the english strings
setappdata(h, 'PopupStrings', objectStrings);
set(h, 'String', popupStrings, 'Value', value);

% [EOF]
