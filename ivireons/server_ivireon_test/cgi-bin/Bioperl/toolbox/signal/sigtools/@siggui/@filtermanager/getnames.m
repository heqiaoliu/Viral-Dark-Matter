function names = getnames(this, jndx)
%GETNAMES   Get the names.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/12/26 22:21:24 $

s = get(this, 'Data');

% Loop over the vector and get the names.
names = {};
for indx = 1:length(s)
    c = s.elementat(indx);
    names{indx} = c.currentName;
end

if nargin > 1
    if jndx == 0
        names = {};
    elseif jndx > length(names)
        name = {};
    else
        names = names(jndx);
    end
end

% [EOF]
