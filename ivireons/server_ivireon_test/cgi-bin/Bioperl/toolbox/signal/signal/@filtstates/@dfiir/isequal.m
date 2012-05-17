function flag = isequal(h,h2)
%ISEQUAL   True if objects are numerically equal.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/01/25 23:08:14 $

flag = true;
flds = fieldnames(get(h));
for n = 1:length(flds),
    flag = isequal(h.(flds{n}),h2.(flds{n}));
end

% [EOF]
