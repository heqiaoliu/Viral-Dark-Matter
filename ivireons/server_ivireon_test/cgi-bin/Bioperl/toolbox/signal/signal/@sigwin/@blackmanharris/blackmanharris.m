function hWIN = blackmanharris(n)
%BLACKMANHARRIS Construct a Blackman-Harris window object
%   H = SIGWIN.BLACKMANHARRIS(N) constructs a Blackman-Harris window object
%   with length N.  If N is not specified, it defaults to 64.
%
%   See also SIGWIN.

%   Author(s): V.Pellissier
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.3.4.3 $  $Date: 2009/05/23 08:15:40 $

hWIN = sigwin.blackmanharris;
hWIN.Name = 'Blackman-Harris';

if nargin>0,
    hWIN.length = n;
end

% [EOF]
