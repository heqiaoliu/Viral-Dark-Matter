function hWIN = parzenwin(n)
%PARZENWIN Construct a Parzen window object
%   H = SIGWIN.PARZENWIN(N) constructs a Parzen window object with length
%   N.  If N is not specified, it defaults to 64.
%
%   See also SIGWIN.

%   Author(s): V.Pellissier
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.4.4.3 $  $Date: 2009/05/23 08:16:00 $

hWIN = sigwin.parzenwin;
hWIN.Name = 'Parzen';

if nargin>0,
    hWIN.length = n;
end

% [EOF]
