function filters = getfilters(this, jndx)
%GETFILTERS   Get the filters.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:23:18 $

s = get(this, 'Data');

if isempty(s)
    filters = [];
    return;
end

% Loop over the vector and get the filters out.
for indx = 1:length(s)
    c = s.elementat(indx);
    filters(indx) = dfilt.dfiltwfs(c.current_filt, c.currentFs, c.currentName);
end

% If we are given a vector use it.
if nargin > 1
    filters = filters(jndx);
end

% [EOF]
