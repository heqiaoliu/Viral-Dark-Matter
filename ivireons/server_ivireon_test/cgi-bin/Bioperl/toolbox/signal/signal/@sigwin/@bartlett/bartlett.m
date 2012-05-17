function hWIN = bartlett(n)
%BARTLETT Bartlett window.
%   H = SIGWIN.BARTLETT(N) returns a N-point Bartlett window object H.
%
%   EXAMPLE:
%     N = 64; 
%     h = sigwin.bartlett(N); 
%     w = generate(h);
%     stem(w); title('64-point Bartlettwindow');
%
%   See also SIGWIN.

%   Author(s): V.Pellissier
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.3.4.3 $  $Date: 2009/05/23 08:15:36 $

hWIN = sigwin.bartlett;
hWIN.Name = 'Bartlett';

if nargin>0,
    hWIN.length = n;
end

% [EOF]
