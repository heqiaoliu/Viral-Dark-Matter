function hWIN = blackman(n, sflag)
%BLACKMAN Construct a Blackmman window object
%   H = SIGWIN.BLACKMAN(N, S) constructs a Blackman window object with
%   length N and sampling flag S.  If N or S is not specified, they default
%   to 64 and 'symmetric' respectively.  The sampling flag can also be
%   'periodic'.
%
%   See also SIGWIN.

%   Author(s): V.Pellissier
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.3.4.5 $  $Date: 2009/05/23 08:15:38 $

hWIN = sigwin.blackman;
hWIN.Name = 'Blackman';

if nargin>0,
    hWIN.length = n;
end

if nargin>1,
    hWIN.SamplingFlag = sflag;
end

% [EOF]
