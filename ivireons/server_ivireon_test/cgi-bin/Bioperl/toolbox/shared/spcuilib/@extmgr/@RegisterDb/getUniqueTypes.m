function typeNames = getUniqueTypes(this)
%GETUNIQUETYPES Return unique type strings registered by extensions.
%  GETUNIQUETYPES(H) returns a cell-array of unique type strings, collected
%  from all extensions registered in database.  This list does not include
%  type registrations, which are extensions themselves - just a type of
%  extension that could be registered.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2007/03/13 19:47:04 $

% If there are no children added yet, shortcut and return {}.
if numChild(this) == 0
    typeNames = {};
else
    typeNames = get(allChild(this), 'Type');
    
    % Prune list to hold just unique names of extensions.  Wrap in CELLSTR
    % in case of a single string.
    typeNames = unique(cellstr(typeNames));
end

% [EOF]
