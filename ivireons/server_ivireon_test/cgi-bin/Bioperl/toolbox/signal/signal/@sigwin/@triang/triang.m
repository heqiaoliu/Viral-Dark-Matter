function hWIN = triang(n)
%TRIANG Construct a Triangular window object
%   H = SIGWIN.TRIANG(N) constructs a Triangular window object with length
%   N.  If N is not specified, it defaults to 64.
%
%   See also SIGWIN.

%   Author(s): V.Pellissier
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.3.4.3 $  $Date: 2009/05/23 08:16:07 $

hWIN = sigwin.triang;
hWIN.Name = 'Triangular';

if nargin>0,
    hWIN.length = n;
end

% [EOF]
