function remove(this, row, col)
%REMOVE   Remove the handle from the manager.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/01/05 18:01:38 $

g = get(this, 'Grid');

if nargin == 2
    h = row;

    [row col] = find(g == h);
    
    g(g == h) = NaN;
    
    % Reset the grid and clean up the listeners vector.
    set(this, ...
        'Grid', g, ...
        'ChildrenListeners', trimChildren(this, min(row), min(col)));
else
    
    g(row, col) = NaN;
    
    % Check if the object is being completely removed.
    [m, n] = getcomponentsize(this, row, col);
    
    set(this, 'Grid', g);
    
    if m == 1 && n == 1
        set(this, 'ChildrenListeners', trimChildren(this, row, col));
    end
end

% -------------------------------------------------------------------------
function listeners = trimChildren(this, row, col)

listeners = this.ChildrenListeners;
listeners{row, col} = [];

% [EOF]
