function str = getstring(h, tag)
%GETSTRING Returns the string at the tag

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/03/02 10:28:23 $

ids = get(h, 'Identifiers');

idx = find(strcmpi(tag, ids));

if isempty(idx),
    str = '';
else
    strs = get(h, 'Strings');
    str  = strs{idx};
end

% [EOF]
