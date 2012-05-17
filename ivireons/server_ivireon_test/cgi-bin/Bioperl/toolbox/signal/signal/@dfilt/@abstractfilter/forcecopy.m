function hcopy = forcecopy(this,h)
%FORCECOPY   Force a copy, i.e., new memory allocation.

%   Author(s): P. Pacheco
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/12/26 22:02:42 $

if strcmpi(class(h),'embedded.fi'),
    hcopy = copy(h);   % force a copy.
elseif isa(h, 'double')
    hcopy = h+0; % Adding a zero forces a copy in MATLAB.
else
    hcopy = h;
end

% [EOF]
