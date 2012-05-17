function hWIN = nuttallwin(n)
%NUTTALLWIN Construct a Nuttall defined minimum 4-term Blackman-Harris window object
%   H = SIGWIN.NUTTALLWIN(N) constructs a Nuttall defined minimum 4-term
%   Blackman-Harris window object with length N.  If N is not specified, it
%   defaults to 64.
%
%   See also SIGWIN.

%   Author(s): V.Pellissier
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.3.4.3 $  $Date: 2009/05/23 08:15:58 $

hWIN = sigwin.nuttallwin;
hWIN.Name = 'Nuttall';

if nargin>0,
    hWIN.length = n;
end

% [EOF]
