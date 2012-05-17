function hWin = taylorwin(n, nbar, sll)
%TAYLORWIN Construct a TAYLORWIN object
%   H = SIGWIN.TAYLORWIN(N, NBAR, SLL) constructs a Taylor window object
%   with length N, number of nearly constant-level sidelobes adjacent to
%   the mainlobe NBAR, and maximum sidelobe level SLL (in dB).  If N, NBAR,
%   and SLL are not specified, their default values are 64, 4, and 30
%   respectively.
%
%   See also SIGWIN.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.10.2 $  $Date: 2009/05/23 08:16:05 $

error(nargchk(0,3, nargin,'struct'));

hWin = sigwin.taylorwin;
hWin.Name = 'Taylor';

createdynamicprops(hWin, 'Nbar', ...
    'posint', 'Number of nearly constant-level sidelobes');

createdynamicprops(hWin, 'SidelobeLevel', ...
    'udouble', 'Maximum sidelobe level');

if nargin>0,
    hWin.Length = n;
end

if nargin>1,
    hWin.Nbar = nbar;
else
    hWin.Nbar = 4;
end

if nargin>2,
    hWin.SidelobeLevel = sll;
else
    hWin.SidelobeLevel = 30;
end

