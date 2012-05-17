function hWIN = bohmanwin(n)
%BOHMANWIN Construct a Bohman window object
%   H = SIGWIN.BOHMANWIN(N) constructs a Bohman window object with length
%   N. If N is not specified, it defaults to 64.
%
%   See also SIGWIN.

%   Author(s): V.Pellissier
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.3.4.3 $  $Date: 2009/05/23 08:15:42 $

hWIN = sigwin.bohmanwin;
hWIN.Name = 'Bohman';

if nargin>0,
    hWIN.length = n;
end

% [EOF]
