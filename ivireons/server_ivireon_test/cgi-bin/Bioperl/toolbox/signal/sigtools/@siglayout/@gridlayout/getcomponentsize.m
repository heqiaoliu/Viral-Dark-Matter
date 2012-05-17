function [m, n] = getcomponentsize(this, indx, jndx)
%GETCOMPONENTSIZE   Get the componentsize.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/06/06 17:06:50 $

g = get(this, 'Grid');

h = g(indx, jndx);

if isnan(h)
    m = 0;
    n = 0;
else
    m = max(find(g(:, jndx) == h)) - indx + 1;
    n = max(find(g(indx,:) == h))  - jndx + 1;
end

if nargout < 2
    m = [m n];
end

% [EOF]
