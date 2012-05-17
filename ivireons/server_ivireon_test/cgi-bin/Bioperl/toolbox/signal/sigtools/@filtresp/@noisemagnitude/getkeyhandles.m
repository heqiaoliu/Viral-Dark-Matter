function h = geth(this)
%GETh   Returns the "key" handles.

%   Author(s): J. Schickler
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/06/27 23:38:00 $

h = get(this, 'Handles');
if isfield(h, 'masks')
    h = rmfield(h, 'masks');
end
if isfield(h, 'legend')
    h = rmfield(h, 'legend');
end
if isfield(h, 'userdefinedmask')
    h = rmfield(h, 'userdefinedmask');
end

h = convert2vector(h);

% [EOF]
