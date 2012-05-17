function insert(this, type, indx)
%INSERT   Insert a row or a column at an index.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/06/06 17:06:52 $

g = get(this, 'Grid');

[rows cols] = size(g);

switch lower(type)
    case 'row'
        g = [g(1:indx-1,:); NaN(1, cols); g(indx:end,:)];
    case 'column'
        g = [g(:, 1:indx-1) NaN(rows, 1) g(:, indx:end)];
end

set(this, 'Grid', g);

% [EOF]
