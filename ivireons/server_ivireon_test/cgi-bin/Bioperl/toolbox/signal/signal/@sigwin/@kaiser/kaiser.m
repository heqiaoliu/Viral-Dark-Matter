function hWIN = kaiser(n, param)
%KAISER Construct a Kaiser object
%   H = SIGWIN.KAISER(N, B) constructs a Kaiser window object with length N
%   and Beta B.  If N or B is not specified, they default to 64 and .5
%   respectively.
%
%   See also SIGWIN.

%   Author(s): V.Pellissier
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.3.4.5 $  $Date: 2009/05/23 08:15:56 $

hWIN = sigwin.kaiser;
hWIN.Name = 'Kaiser';
createdynamicprops(hWIN, 'Beta', 'double','Beta');

if nargin>0,
    hWIN.length = n;
end

if nargin>1,
    hWIN.Beta = param;
else
    hWIN.Beta = 0.5;
end

% [EOF]
