function setstring(h, tag, newstr)
%SETSTRINGS

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/03/02 10:28:30 $

ids = get(h, 'Identifiers');

idx = find(strcmpi(tag, ids));

if ~isempty(idx),
    strs = get(h, 'Strings');
    strs{idx} = newstr;
    set(h, 'Strings', strs);
end

% [EOF]
