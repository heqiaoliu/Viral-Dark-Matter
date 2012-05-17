function clean(this)
%CLEAN   Clean the grid.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/06/06 17:06:48 $

g = get(this, 'Grid');

[rows cols] = size(g);

% Clean up any extra rows in the grid.
indx = rows;
while indx > 0 && all(isnan(g(indx,:)))
    g(indx,:) = [];
    indx      = indx-1;
end

indx = cols;
while indx > 0 && all(isnan(g(:,indx)))
    g(:,indx) = [];
    indx      = indx-1;
end

set(this, 'Grid', g);

% [EOF]
