function hWIN = chebwin(n, atten)
%CHEBWIN Construct a Chebyshev object
%   H = SIGWIN.CHEBWIN(N, S) constructs a Chebyshev window object with
%   length N and sidelobe attenuation S.  If N or S is not specified, they
%   default to 64 and 100 respectively.
%
%   See also SIGWIN.

%   Author(s): V.Pellissier
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.3.4.6 $  $Date: 2009/05/23 08:15:44 $

hWIN = sigwin.chebwin;
hWIN.Name = 'Chebyshev';
createdynamicprops(hWIN, 'SidelobeAtten', 'double', 'Sidelobe Attenuation');

if nargin>0,
    hWIN.length = n;
end

if nargin>1,
    hWIN.SidelobeAtten = atten;
else
    hWIN.SidelobeAtten = 100;
end

% [EOF]
