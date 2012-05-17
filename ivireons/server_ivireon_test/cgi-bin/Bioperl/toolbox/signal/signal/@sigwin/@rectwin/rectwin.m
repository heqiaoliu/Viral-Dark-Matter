function hWIN = rectwin(n)
%RECTWIN Construct a Rectangular window object
%   H = SIGWIN.RECTWIN(N) constructs a Rectangular window object with length
%   N.  If N is not specified, it defaults to 64.
%
%   See also SIGWIN.

%   Author(s): V.Pellissier
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.3.4.3 $  $Date: 2009/05/23 08:16:02 $

hWIN = sigwin.rectwin;
hWIN.Name = 'Rectangular';

if nargin>0,
    hWIN.length = n;
end

% [EOF]
