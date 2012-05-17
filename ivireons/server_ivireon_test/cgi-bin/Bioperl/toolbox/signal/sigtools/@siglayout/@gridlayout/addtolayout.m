function addtolayout(this, h, row, col)
%ADDTOLAYOUT   Add the component to the grid.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/01/05 18:01:33 $

g = get(this, 'Grid');

g(min(row):max(row), min(col):max(col)) = h;

% Convert any added zeros to NaN.
g(g == 0) = NaN;

set(this, 'Grid', g);

if ~isnan(h)

    this.ChildrenListeners{min(row), min(col)} = uiservices.addlistener(h, ...
        'ObjectBeingDestroyed', @(hSrc, ev) remove(this, h));
end

% [EOF]
