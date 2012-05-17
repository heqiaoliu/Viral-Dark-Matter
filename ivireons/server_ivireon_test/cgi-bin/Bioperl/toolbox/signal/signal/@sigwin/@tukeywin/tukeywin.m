function hWIN = tukeywin(n, param)
%TUKEYWIN Construct a Tukey object
%   H = SIGWIN.TUKEYWIN(N, A) constructs a Tukey window object with length
%   N and Alpha A.  If N or A is not specified, they default to 64 and .5
%   respectively.
%
%   See also SIGWIN.

%   Author(s): V.Pellissier
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.3.4.5 $  $Date: 2009/05/23 08:16:09 $

hWIN = sigwin.tukeywin;
hWIN.Name = 'Tukey';
createdynamicprops(hWIN, 'Alpha', 'double','Alpha');

if nargin>0,
    hWIN.length = n;
end

if nargin>1,
    hWIN.Alpha = param;
else
    hWIN.Alpha = 0.5;
end

% [EOF]
