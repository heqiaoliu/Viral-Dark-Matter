function updatenumbers(this)
%UPDATENUMBERS Update the numbers

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/01/05 18:00:59 $

h = get(this, 'Handles');

roots = get(this, 'Roots');

if isfield(h, 'numbers'),
    delete(h.numbers(ishghandle(h.numbers)));
end
h.numbers = [];

if ~isempty(roots),
    h.numbers = drawpznumbers(double(roots, 'conj'), h.axes, 'Visible', this.Visible);
end
set(this, 'Handles', h);

% [EOF]
